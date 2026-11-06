-- ============================================================
-- SERVER AVAILABILITY / SELECTION
-- ============================================================
--
-- Mason prepends its bin directory to $PATH, but the LSP config is loaded
-- before/independent of that in some start orders, so check the explicit
-- Mason path as well as $PATH.

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

local function executable_any(name)
    for _, path in ipairs({ mason_bin .. "/" .. name, name }) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    return nil
end

local function read_json(path)
    local fd = io.open(path, "r")
    if not fd then
        return nil
    end

    local content = fd:read("*a")
    fd:close()

    local ok, decoded = pcall(vim.json.decode, content)
    return ok and decoded or nil
end

-- `ts_ls` wraps tsserver and its published packages only support TypeScript
-- < 7. The Mason package deliberately bundles a compatible TypeScript, so
-- prefer that installation. Fall back to checking the global compiler only
-- when Mason has not installed ts_ls yet.
local function ts_ls_available()
    if not executable_any("typescript-language-server") then
        return false
    end

    local bundled = read_json(mason_packages .. "/typescript-language-server/node_modules/typescript/package.json")
    local version = bundled and bundled.version

    if not version then
        local out = vim.fn.system({ "tsc", "--version" })
        if vim.v.shell_error == 0 then
            version = out:match("(%d+%.%d+%.%d+)")
        end
    end

    if not version then
        return false
    end

    local major = tonumber(version:match("^(%d+)"))
    return major ~= nil and major < 7
end

local ts_ls_ok = ts_ls_available()

-- Users can force a server with `vim.g.typescript_lsp = "vtsls"` or
-- `"ts_ls"` in init.lua. Without an override, ts_ls wins when compatible and
-- vtsls is used as the fallback.
local typescript_preference = vim.g.typescript_lsp
local use_ts_ls = ts_ls_ok and typescript_preference ~= "vtsls"
local use_vtsls = executable_any("vtsls") ~= nil
    and not use_ts_ls
    and (typescript_preference ~= "ts_ls" or not ts_ls_ok)

local basedpyright_available = executable_any("basedpyright-langserver") ~= nil
local eslint_available = executable_any("vscode-eslint-language-server") ~= nil
local pylsp_available = executable_any("pylsp") ~= nil

-- Python works the same way as TypeScript: one server at a time. basedpyright
-- is the default because it ships typeshed and strict checks out of the box;
-- pylsp is the fallback and can be forced with `vim.g.python_lsp = "pylsp"`.
local python_preference = vim.g.python_lsp
local use_basedpyright = basedpyright_available
    and (python_preference ~= "pylsp" or not pylsp_available)
local use_pylsp = pylsp_available and not use_basedpyright

-- Shared by ts_ls and vtsls; both expose the same `typescript`/`javascript`
-- configuration namespaces.
local typescript_settings = {
    typescript = {
        suggest = {
            completeFunctionCalls = true,
        },

        inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
        },

        preferences = {
            includePackageJsonAutoImports = "auto",
            importModuleSpecifier = "shortest",
            quoteStyle = "auto",
        },
    },

    javascript = {
        suggest = {
            completeFunctionCalls = true,
        },

        inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
        },

        preferences = {
            includePackageJsonAutoImports = "auto",
            importModuleSpecifier = "shortest",
            quoteStyle = "auto",
        },
    },
}

return {
    -- ============================================================
    -- BASH
    -- ============================================================

    bashls = {
        filetypes = { "bash", "sh", "zsh" },

        settings = {
            bashIde = {
                globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.bash|.zsh|.env|.envrc|.ksh|PKGBUILD)",

                shellcheckPath = "shellcheck",
            },
        },
    },

    -- ============================================================
    -- CLANGD
    -- ============================================================

    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--all-scopes-completion",
            "--clang-tidy",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--header-insertion=iwyu",
            "--fallback-style=WebKit",
            "--log=error",

            "--query-driver=/usr/bin/arm-none-eabi-*,"
                .. "/opt/homebrew/bin/*,"
                .. "/usr/local/bin/*,"
                .. "/usr/bin/*gcc*,"
                .. "/usr/bin/*g++,"
                .. "/usr/bin/clang*,"
                .. "/Library/Developer/CommandLineTools/usr/bin/*",
        },

        filetypes = {
            "c",
            "cpp",
            "objc",
            "objcpp",
        },

        before_init = function(_, config)
            local root = config.root_dir or vim.fn.getcwd()

            local platformio_ini = vim.fn.glob(root .. "/platformio.ini")

            local opts = vim.deepcopy(config.init_options or {})

            if platformio_ini ~= "" then
                local compile_commands = root .. "/compile_commands.json"

                local already_exists = vim.fn.filereadable(compile_commands) == 1

                if not already_exists then
                    vim.system({
                        "pio",
                        "run",
                        "--target",
                        "compiledb",
                    }, {
                        cwd = root,
                    }, function(obj)
                        vim.schedule(function()
                            if obj.code ~= 0 then
                                vim.notify(
                                    "PlatformIO: Failed to generate compile_commands.json\n" .. (obj.stderr or ""),
                                    vim.log.levels.WARN,
                                    {
                                        title = "clangd/PlatformIO",
                                    }
                                )

                                return
                            end

                            vim.notify(
                                "PlatformIO: compile_commands.json generated, restarting clangd",
                                vim.log.levels.INFO,
                                {
                                    title = "clangd/PlatformIO",
                                }
                            )

                            -- :LspStart is not defined by nvim-lspconfig on Nvim 0.12+
                            vim.cmd(vim.fn.exists(":lsp") == 2 and "lsp restart clangd" or "LspRestart clangd")
                        end)
                    end)
                end

                opts.compilationDatabasePath = root
            end

            config.init_options = opts
        end,
    },

    -- ============================================================
    -- CSS
    -- ============================================================

    cssls = {
        settings = {
            css = {
                validate = true,

                lint = {
                    unknownAtRules = "ignore",
                },
            },

            scss = {
                validate = true,
            },

            less = {
                validate = true,
            },
        },
    },

    -- ============================================================
    -- TAILWIND
    -- ============================================================

    tailwindcss = {
        filetypes = {
            "html",
            "css",
            "scss",
            "less",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
            "astro",
        },
    },

    -- ============================================================
    -- EMMET
    -- ============================================================

    emmet_language_server = {
        filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "pug",
            "sass",
            "scss",
            "typescriptreact",
        },
    },

    -- ============================================================
    -- ESLINT (JavaScript / TypeScript linting)
    -- ============================================================

    eslint = {
        -- Only activates in projects that actually contain an ESLint config;
        -- the default root_dir returns nil otherwise.
        _when = function()
            return eslint_available
        end,

        settings = {
            -- Keep diagnostics quiet while typing. Linting happens on save
            -- (autosave is enabled), and code actions remain available.
            run = "onSave",
            validate = "on",
            workingDirectory = { mode = "auto" },
        },
    },

    -- ============================================================
    -- HTML
    -- ============================================================

    html = {
        filetypes = {
            "html",
            "templ",
        },
    },

    -- ============================================================
    -- JSON
    -- ============================================================

    jsonls = {
        settings = {
            json = {
                validate = {
                    enable = true,
                },

                format = {
                    enable = true,
                },
            },
        },

        -- on_new_config is an old lspconfig hook that vim.lsp.config never calls;
        -- before_init runs before the settings are sent to the server.
        before_init = function(_, config)
            local ok, schemastore = pcall(require, "schemastore")

            if ok then
                config.settings = config.settings or {}
                config.settings.json = config.settings.json or {}
                config.settings.json.schemas = schemastore.json.schemas()
            end
        end,
    },

    -- ============================================================
    -- LUA
    -- ============================================================

    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },

                completion = {
                    autoRequire = true,
                    callSnippet = "Replace",
                },

                diagnostics = {
                    globals = {
                        "vim",
                    },
                },

                hint = {
                    enable = true,
                    arrayIndex = "Disable",
                    paramName = "Disable",
                    paramType = true,
                    setType = true,
                },

                workspace = {
                    checkThirdParty = false,
                },

                telemetry = {
                    enable = false,
                },
            },
        },
    },

    -- ============================================================
    -- PYTHON / BASEDPYRIGHT
    -- ============================================================

    basedpyright = {
        _when = function()
            return use_basedpyright
        end,

        settings = {
            basedpyright = {
                analysis = {
                    -- Only diagnose files you currently have open.
                    diagnosticMode = "openFilesOnly",

                    -- Good balance between useful checking and noise.
                    typeCheckingMode = "standard",

                    -- Let basedpyright discover normal Python paths.
                    autoSearchPaths = true,

                    -- Use installed package source/type information.
                    useLibraryCodeForTypes = true,

                    -- Enable automatic import suggestions.
                    autoImportCompletions = true,

                    -- Useful Python type information in the editor.
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        callArgumentNames = true,
                    },
                },
            },
        },
    },

    -- ============================================================
    -- PYTHON / PYLSP FALLBACK
    -- ============================================================

    pylsp = {
        -- used only when basedpyright is unavailable (or is explicitly
        -- overridden with `vim.g.python_lsp = "pylsp"`), so both servers
        -- never attach to the same buffer
        _when = function()
            return use_pylsp
        end,

        settings = {
            pylsp = {
                plugins = {
                    jedi_completion = {
                        include_params = true,
                    },
                    jedi_hover = {
                        enabled = true,
                    },
                },
            },
        },
    },

    -- ============================================================
    -- MARKDOWN
    -- ============================================================

    marksman = {
        filetypes = {
            "markdown",
            "markdown.mdx",
        },
    },

    -- ============================================================
    -- QML
    -- ============================================================

    qmlls = {
        filetypes = {
            "qml",
        },
    },

    -- ============================================================
    -- SQL
    -- ============================================================

    sqls = {
        filetypes = { "sql", "mysql", "plsql" },
        root_dir = function(fname)
            return vim.fn.getcwd()
        end,
        settings = {
            sqls = {
                -- Connections can be added here per-project; sqls will
                -- introspect the schema for table/column completion.
                connections = {
                    {
                        driver = "mysql",
                        dataSourceName = "root@tcp(127.0.0.1:3306)/practicedb?parseTime=true",
                    },
                },
            },
        },
    },

    -- ============================================================
    -- TYPESCRIPT / JAVASCRIPT
    -- ============================================================
    --
    -- Exactly one of ts_ls/vtsls is enabled. ts_ls is preferred when a
    -- TypeScript < 7 runtime is available (Mason bundles one); vtsls is the
    -- fallback for machines where only TypeScript 7+ exists.
    -- No Deno conflict: both lspconfig root_dir implementations skip Deno
    -- projects, and Deno itself is not enabled.

    ts_ls = {
        _when = function()
            return use_ts_ls
        end,

        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },

        settings = typescript_settings,
    },

    vtsls = {
        _when = function()
            return use_vtsls
        end,

        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },

        settings = typescript_settings,
    },

    -- ============================================================
    -- YAML
    -- ============================================================

    yamlls = {
        settings = {
            yaml = {
                keyOrdering = false,

                format = {
                    enable = true,
                },

                validate = true,
            },
        },

        before_init = function(_, config)
            local ok, schemastore = pcall(require, "schemastore")

            if ok then
                config.settings = config.settings or {}
                config.settings.yaml = config.settings.yaml or {}
                -- Use SchemaStore.nvim's catalogue instead of yamlls' built-in download
                config.settings.yaml.schemaStore = { enable = false, url = "" }
                config.settings.yaml.schemas = schemastore.yaml.schemas()
            end
        end,
    },
}
