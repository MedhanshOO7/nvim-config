return {
    "FabijanZulj/blame.nvim",
    cmd = "BlameToggle",
    keys = {
        { "<leader>gB", "<cmd>BlameToggle window<cr>", desc = "Git: Toggle Blame Window" },
        { "<leader>gb", "<cmd>BlameToggle virtual<cr>", desc = "Git: Toggle Inline Blame" },
    },
    opts = {
        date_format = "%Y-%m-%d %H:%M",
        virtual_style = "right_align",
        views = {
            window = {
                border = "rounded",
            },
            virtual = {
                style = "right_align",
            },
        },
    },
}
