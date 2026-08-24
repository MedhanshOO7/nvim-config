return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "giuxtaposition/blink-cmp-copilot",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
        keymap = {
            preset = "none",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = {
                function(cmp)
                    local copilot_ok, copilot_suggestion = pcall(require, "copilot.suggestion")
                    if copilot_ok and copilot_suggestion.is_visible() then
                        copilot_suggestion.accept()
                        return true
                    end
                    if cmp.snippet_active() then
                        return cmp.accept()
                    elseif cmp.is_visible() then
                        return cmp.select_and_accept()
                    end
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "copilot", "lazydev" },
            providers = {
                copilot = {
                    name = "copilot",
                    module = "blink-cmp-copilot",
                    score_offset = 100,
                    async = true,
                    transform_items = function(_, items)
                        local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
                        local kind_idx = #CompletionItemKind + 1
                        CompletionItemKind[kind_idx] = "Copilot"
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
                    score_offset = 80,
                },
            },
            per_filetype = {
                sql = { "dadbod", "buffer" },
                mysql = { "dadbod", "buffer" },
                plsql = { "dadbod", "buffer" },
            },
        },
        completion = {
            accept = {
                auto_brackets = { enabled = true },
            },
            menu = {
                border = "rounded",
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
                auto_show_delay_ms = 150,
                window = {
                    border = "rounded",
                },
            },
            ghost_text = {
                enabled = false,
            },
        },
        signature = {
            enabled = true,
            window = {
                border = "rounded",
            },
        },
    },
}
