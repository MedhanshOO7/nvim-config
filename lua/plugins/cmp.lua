return {
    "saghen/blink.cmp",
    -- Pin the stable v1 line. v2 is still in development and changes the
    -- configuration API (completion.list, sources, keymap commands, ...).
    version = "1.*",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "giuxtaposition/blink-cmp-copilot",
        "L3MON4D3/LuaSnip",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
        keymap = {
            preset = "none",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "cancel", "fallback" },
            -- With selection.preselect = false this only accepts an item the
            -- user explicitly selected; otherwise it falls back to a normal
            -- <CR> (newline / indentation).
            ["<CR>"] = { "accept", "fallback" },

            -- Contextual Tab, highest priority first:
            --   1. an inline Copilot suggestion (when the plugin is active)
            --   2. an active LuaSnip placeholder
            --   3. an explicitly selected completion item
            --   4. the completion menu (select the first item)
            --   5. normal indentation
            ["<Tab>"] = {
                function(cmp)
                    local copilot_ok, copilot = pcall(require, "copilot.suggestion")
                    if copilot_ok and copilot.is_visible() then
                        copilot.accept()
                        return true
                    end

                    if cmp.snippet_active({ direction = 1 }) then
                        return cmp.snippet_forward()
                    end

                    if cmp.is_menu_visible() then
                        if cmp.accept() then
                            return true
                        end
                        return cmp.select_next()
                    end
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = {
                function(cmp)
                    if cmp.snippet_active({ direction = -1 }) then
                        return cmp.snippet_backward()
                    end
                    if cmp.is_menu_visible() then
                        return cmp.select_prev()
                    end
                end,
                "snippet_backward",
                "fallback",
            },

            ["<C-n>"] = { "select_next", "fallback_to_mappings" },
            ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-k>"] = { "show_signature", "hide_signature", "fallback_to_mappings" },
        },

        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
            kind_icons = {
                Copilot = "󰚩",
                Text = "󰉿",
                Method = "󰊕",
                Function = "󰊕",
                Constructor = "󰒓",
                Field = "󰜢",
                Variable = "󰆦",
                Class = "󰌗",
                Interface = "󱡠",
                Module = "󰅩",
                Property = "󰜢",
                Unit = "󰪚",
                Value = "󰦨",
                Enum = "󰦨",
                Keyword = "󰌋",
                Snippet = "󰔓",
                Color = "󰏘",
                File = "󰈔",
                Reference = "󰬲",
                Folder = "󰉋",
                EnumMember = "󰦨",
                Constant = "󰏿",
                Struct = "󰌗",
                Event = "󱐋",
                Operator = "󰆕",
                TypeParameter = "󰅲",

                -- Database kinds
                Table = "󰓫",
                Column = "󰜢",
                Database = "󰆼",
                Schema = "",
                Alias = "󰡱",
            },
        },

        -- Use LuaSnip as blink.cmp's snippet engine.
        snippets = {
            preset = "luasnip",
        },

        sources = {
            default = { "lsp", "snippets", "path", "buffer", "copilot", "lazydev" },

            providers = {
                lsp = {
                    name = "lsp",
                    module = "blink.cmp.sources.lsp",
                    transform_items = function(_, items)
                        local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
                        local custom_kinds = { "Table", "Column", "Database", "Alias" }

                        for _, name in ipairs(custom_kinds) do
                            local found = false
                            for _, v in ipairs(CompletionItemKind) do
                                if v == name then
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                CompletionItemKind[#CompletionItemKind + 1] = name
                            end
                        end

                        local function get_kind_idx(name)
                            for idx, v in ipairs(CompletionItemKind) do
                                if v == name then
                                    return idx
                                end
                            end
                            return nil
                        end

                        local table_idx = get_kind_idx("Table")
                        local col_idx = get_kind_idx("Column")

                        for _, item in ipairs(items) do
                            local kind = item.kind
                            -- sqls sends Field for columns and Struct for tables typically
                            if kind == CompletionItemKind.Field then
                                item.kind = col_idx
                            elseif kind == CompletionItemKind.Struct then
                                item.kind = table_idx
                            end
                        end

                        return items
                    end,
                },
                copilot = {
                    name = "copilot",
                    module = "blink-cmp-copilot",
                    score_offset = 100,
                    async = true,

                    transform_items = function(_, items)
                        local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
                        local kind_idx = CompletionItemKind.Copilot

                        if not kind_idx then
                            kind_idx = #CompletionItemKind + 1
                            CompletionItemKind[kind_idx] = "Copilot"
                        end

                        for _, item in ipairs(items) do
                            item.kind = kind_idx
                        end

                        return items
                    end,
                },

                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100,
                },

                dadbod = {
                    name = "Dadbod",
                    module = "vim_dadbod_completion.blink",
                    score_offset = 85,

                    transform_items = function(_, items)
                        local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
                        local custom_kinds = { "Table", "Column", "Database", "Alias" }

                        for _, name in ipairs(custom_kinds) do
                            local found = false

                            for _, v in ipairs(CompletionItemKind) do
                                if v == name then
                                    found = true
                                    break
                                end
                            end

                            if not found then
                                CompletionItemKind[#CompletionItemKind + 1] = name
                            end
                        end

                        local function get_kind_idx(name)
                            for idx, v in ipairs(CompletionItemKind) do
                                if v == name then
                                    return idx
                                end
                            end

                            return nil
                        end

                        local table_idx = get_kind_idx("Table")
                        local col_idx = get_kind_idx("Column")
                        local db_idx = get_kind_idx("Database")
                        local alias_idx = get_kind_idx("Alias")

                        for _, item in ipairs(items) do
                            local doc = (item.documentation or ""):lower()

                            if doc:find("alias") then
                                if alias_idx then
                                    item.kind = alias_idx
                                end
                            elseif doc:find("column") then
                                if col_idx then
                                    item.kind = col_idx
                                end
                            elseif doc:find("table") then
                                if table_idx then
                                    item.kind = table_idx
                                end
                            elseif doc:find("schema") or doc:find("database") then
                                if db_idx then
                                    item.kind = db_idx
                                end
                            end
                        end

                        return items
                    end,
                },
            },

per_filetype = {
    sql = { "dadbod", "lsp", "buffer", "snippets" },
    mysql = { "dadbod", "lsp", "buffer", "snippets" },
    plsql = { "dadbod", "lsp", "buffer", "snippets" },
},
        },

        -- Fuzzy matching and frecency are on by default; keep them explicit so
        -- the behaviour is visible and easy to tune.
        fuzzy = {
            implementation = "prefer_rust_with_warning",
            use_proximity = true,
            frecency = { enabled = true },
        },

        completion = {
            -- Insert () and quotes only when the server item asks for it.
            -- nvim-autopairs is installed, so blink defers to it instead of
            -- fighting over the same characters.
            accept = {
                auto_brackets = { enabled = true },
            },

            -- Never preselect and never auto-insert preview text. The menu is
            -- a list to opt into, not a mode that mutates the buffer.
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },

            menu = {
                border = "rounded",
                max_height = 12,
                draw = {
                    treesitter = { "lsp" },
                    columns = {
                        { "kind_icon", "label", "label_description", gap = 1 },
                        { "kind" },
                        { "source_name" },
                    },
                },
            },

            documentation = {
                auto_show = true,
                auto_show_delay_ms = 400,
                treesitter_highlighting = true,
                window = {
                    border = "rounded",
                    max_width = 80,
                    max_height = 20,
                    scrollbar = true,
                },
            },

            -- Subtle inline preview. Toggle with <leader>ug.
            ghost_text = {
                enabled = function()
                    return vim.g.blink_ghost_text ~= false
                end,
                show_with_selection = true,
                show_without_selection = true,
                show_with_menu = true,
                show_without_menu = true,
            },
        },

        -- signature = {
        --     enabled = true,
        --     window = {
        --         border = "rounded",
        --     },
        -- },
        signature = {
            enabled = true,
            window = {
                border = "rounded",
                max_height = 10,
                scrollbar = true,
            },
        },
    },
}
