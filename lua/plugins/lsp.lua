return {
    "neovim/nvim-lspconfig",

    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
        "saghen/blink.cmp",
        "folke/lazydev.nvim",
        "b0o/schemastore.nvim",
    },

    config = function()
        local function cmd(command)
            return "<cmd>" .. command .. "<CR>"
        end

        local function smart_code_action()
            local ok, tiny = pcall(require, "tiny-code-action")

            if ok then
                tiny.code_action()
                return
            end

            vim.lsp.buf.code_action()
        end

        local function smart_rename()
            vim.lsp.buf.rename()
        end

        -- ============================================================
        -- LSP CAPABILITIES
        -- ============================================================

        local capabilities = vim.lsp.protocol.make_client_capabilities()

        local blink_ok, blink = pcall(require, "blink.cmp")

        if blink_ok then
            -- get_lsp_capabilities merges Blink's completion/signature
            -- capabilities into the table we pass in, rather than replacing
            -- the base client capabilities.
            capabilities = blink.get_lsp_capabilities(capabilities)
        end

        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        -- ============================================================
        -- UI
        -- ============================================================

        local float_border = {
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
        }

        local function bordered(config)
            return vim.tbl_deep_extend("force", config or {}, {
                border = float_border,
                focusable = false,
                max_width = math.floor(vim.o.columns * 0.40),
                max_height = math.floor(vim.o.lines * 0.25),
            })
        end

        -- ============================================================
        -- INLAY HINTS
        -- ============================================================

        local function toggle_inlay_hints(bufnr)
            if not vim.lsp.inlay_hint then
                vim.notify("Inlay hints are not supported in this Neovim build", vim.log.levels.WARN)
                return
            end

            local enabled = vim.lsp.inlay_hint.is_enabled({
                bufnr = bufnr,
            })

            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })

            vim.notify(not enabled and "Inlay hints are on" or "Inlay hints are off")
        end

        -- Toggle every LSP client attached to one buffer, then re-run the
        -- FileType event to let vim.lsp.enable attach them again on the same
        -- buffer. This avoids reloading the file and losing undo history.
        local function toggle_lsp_buffer(bufnr)
            bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr

            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end

            local clients = vim.lsp.get_clients({ bufnr = bufnr })

            if #clients > 0 then
                vim.b[bufnr].lsp_suspended = true

                for _, client in ipairs(clients) do
                    pcall(vim.lsp.buf_detach_client, bufnr, client.id)
                end

                vim.notify("LSP detached for this buffer", vim.log.levels.INFO)
                return
            end

            vim.b[bufnr].lsp_suspended = false
            vim.api.nvim_buf_call(bufnr, function()
                vim.cmd("silent! doautocmd <nomodeline> FileType")
            end)

            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) and #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
                    vim.notify("No language server reattached to this buffer", vim.log.levels.WARN)
                end
            end, 500)
        end

        vim.keymap.set("n", "<leader>ll", function()
            toggle_lsp_buffer(0)
        end, { desc = "Toggle LSP for this buffer" })

        -- ============================================================
        -- LAZYDEV
        -- ============================================================

        local lazydev_ok, lazydev = pcall(require, "lazydev")

        if lazydev_ok then
            lazydev.setup({
                library = {
                    {
                        path = "${3rd}/luv/library",
                        words = { "vim%.uv" },
                    },
                },
            })
        end

        -- ============================================================
        -- DIAGNOSTICS
        -- ============================================================

        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = false,

            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },

                numhl = {},
            },

            underline = {
                severity = {
                    min = vim.diagnostic.severity.WARN,
                },
            },

            update_in_insert = false,

            severity_sort = true,

            float = {
                border = float_border,
                source = "if_many",
                scope = "cursor",

                max_width = math.floor(vim.o.columns * 0.6),
                max_height = math.floor(vim.o.lines * 0.4),
            },
        })

        -- LSP progress, hover and signature help are rendered by noice.nvim
        -- (lua/plugins/noice.lua). Don't override those handlers here: a
        -- handler installed after noice loads silently replaces noice's.

        -- ============================================================
        -- SERVER CONFIGURATION
        -- ============================================================

        local servers_ok, servers = pcall(require, "lsp.servers")

        if not servers_ok then
            vim.notify("Failed to load LSP servers config", vim.log.levels.ERROR)

            servers = {}
        end

        vim.keymap.set("n", "<leader>lR", function()
            -- `:lsp` is built in from 0.12; nvim-lspconfig provides :LspRestart on 0.11
            vim.cmd(vim.fn.exists(":lsp") == 2 and "lsp restart" or "LspRestart")
        end, {
            desc = "Restart language servers",
        })

        -- ============================================================
        -- ENABLE LSP SERVERS
        -- ============================================================

        for server, server_config in pairs(servers) do
            local config = vim.deepcopy(server_config)

            -- `_when` is our selector, not a field Neovim understands.
            local when = config._when
            config._when = nil

            local enabled = true
            if type(when) == "function" then
                local ok, result = pcall(when)
                enabled = ok and result == true
            elseif when ~= nil then
                enabled = when == true
            end

            if enabled then
                vim.lsp.config(server, vim.tbl_deep_extend("force", {
                    capabilities = capabilities,
                }, config))
                vim.lsp.enable(server)
            else
                -- Make sure a previous session/plugin did not leave it on.
                vim.lsp.enable(server, false)
            end
        end

        -- ============================================================
        -- LSP ATTACH
        -- ============================================================

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),

            callback = function(event)
                -- Disable LSP for very large files.
                if vim.b[event.buf].large_file or vim.b[event.buf].bigfile then
                    vim.schedule(function()
                        pcall(vim.lsp.buf_detach_client, event.buf, event.data.client_id)
                    end)

                    return
                end

                -- The user explicitly suspended LSP in this buffer.
                if vim.b[event.buf].lsp_suspended then
                    vim.schedule(function()
                        pcall(vim.lsp.buf_detach_client, event.buf, event.data.client_id)
                    end)

                    return
                end

                local client = vim.lsp.get_client_by_id(event.data.client_id)

                local function map_lsp(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = event.buf,
                        desc = desc,
                    })
                end

                vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                -- Semantic highlighting sits on top of Treesitter (Treesitter
                -- keeps strings, comments and markup; LSP adds semantic
                -- modifiers such as parameter/readonly).
                if client and client:supports_method("textDocument/semanticTokens/full") then
                    vim.lsp.semantic_tokens.enable(true, {
                        bufnr = event.buf,
                        client_id = client.id,
                    })
                end

                -- Diagnostics.
                map_lsp("n", "<leader>le", function()
                    vim.diagnostic.open_float(bordered({
                        scope = "cursor",
                        source = "if_many",
                    }))
                end, "Explain the problem on this line")

                -- Navigation.
                map_lsp("n", "<leader>ld", vim.lsp.buf.definition, "Jump to where this symbol is defined")

                map_lsp("n", "<leader>lD", vim.lsp.buf.declaration, "Jump to where this symbol is declared")

                map_lsp("n", "<leader>li", vim.lsp.buf.implementation, "Jump to the implementation")

                map_lsp("n", "<leader>lo", function()
                    require("snacks").picker.lsp_symbols()
                end, "Search symbols in this file")

                map_lsp("n", "<leader>ls", function()
                    require("snacks").picker.lsp_workspace_symbols()
                end, "Search workspace symbols")

                map_lsp("n", "<leader>lt", vim.lsp.buf.type_definition, "Jump to the type definition")

                map_lsp("n", "gd", vim.lsp.buf.definition, "Jump to where this symbol is defined")

                map_lsp("n", "gD", vim.lsp.buf.declaration, "Jump to where this symbol is declared")

                map_lsp("n", "gr", vim.lsp.buf.references, "Show every place this symbol is used")

                map_lsp("n", "gi", vim.lsp.buf.implementation, "Jump to the implementation")

                map_lsp("n", "K", vim.lsp.buf.hover, "Show documentation for the symbol under the cursor")

                -- Diagnostics navigation.
                map_lsp("n", "[d", function()
                    vim.diagnostic.jump({
                        count = -1,
                        float = true,
                    })
                end, "Go to the previous diagnostic")

                map_lsp("n", "]d", function()
                    vim.diagnostic.jump({
                        count = 1,
                        float = true,
                    })
                end, "Go to the next diagnostic")

                -- Signature help.
                map_lsp("n", "<leader>lk", vim.lsp.buf.signature_help, "Show function signature help")

                if client and client:supports_method("textDocument/signatureHelp") then
                    map_lsp("n", "<C-k>", vim.lsp.buf.signature_help, "Show function signature help")
                end

                -- Rename.
                map_lsp("n", "<leader>rn", smart_rename, "Rename this symbol everywhere")

                -- Code actions.
                map_lsp({ "n", "v" }, "<leader>ca", smart_code_action, "Show suggested code fixes and actions")

                -- Inlay hints.
                if client and client:supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
                    map_lsp("n", "<leader>lI", function()
                        toggle_inlay_hints(event.buf)
                    end, "Turn inlay hints on or off")
                end
            end,
        })

        -- ============================================================
        -- LSP DETACH
        -- ============================================================

        vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("user_lsp_detach", { clear = true }),

            callback = function(event)
                pcall(vim.lsp.buf.clear_references)

                -- Attach/detach is routine; showing a notification for every
                -- server is noise. Failures are still reported by Neovim.
                if vim.g.lsp_debug then
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client then
                        vim.schedule(function()
                            vim.notify("LSP: " .. client.name .. " detached", vim.log.levels.WARN, { title = "LSP" })
                        end)
                    end
                end
            end,
        })
    end,
}
