return {
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
            input = {
                enabled = false, -- snacks.input handles vim.ui.input
            },
            select = {
                enabled = true,
                backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
                builtin = {
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                },
            },
        },
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
    },
}
