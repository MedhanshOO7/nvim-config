return {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
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
        { "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", desc = "Git Conflict: Choose Ours" },
        { "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Git Conflict: Choose Theirs" },
        { "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", desc = "Git Conflict: Choose Both" },
        { "<leader>gc0", "<cmd>GitConflictChooseNone<cr>", desc = "Git Conflict: Choose None" },
        { "<leader>gc]", "<cmd>GitConflictNextConflict<cr>", desc = "Git Conflict: Next Conflict" },
        { "<leader>gc[", "<cmd>GitConflictPrevConflict<cr>", desc = "Git Conflict: Prev Conflict" },
        { "<leader>gcq", "<cmd>GitConflictListQf<cr>", desc = "Git Conflict: Quickfix list" },
    },
}
