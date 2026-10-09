return {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
        default_mappings = true,
        default_commands = true,
        disable_diagnostics = false,
        highlights = {
            incoming = "DiffAdd",
            current = "DiffText",
        },
    },
    keys = {
        { "<leader>gCo", "<cmd>GitConflictChooseOurs<cr>", desc = "Git Conflict: Choose Ours" },
        { "<leader>gCt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Git Conflict: Choose Theirs" },
        { "<leader>gCb", "<cmd>GitConflictChooseBoth<cr>", desc = "Git Conflict: Choose Both" },
        { "<leader>gC0", "<cmd>GitConflictChooseNone<cr>", desc = "Git Conflict: Choose None" },
        { "<leader>gC]", "<cmd>GitConflictNextConflict<cr>", desc = "Git Conflict: Next Conflict" },
        { "<leader>gC[", "<cmd>GitConflictPrevConflict<cr>", desc = "Git Conflict: Prev Conflict" },
        { "<leader>gCq", "<cmd>GitConflictListQf<cr>", desc = "Git Conflict: Quickfix list" },
    },
}
