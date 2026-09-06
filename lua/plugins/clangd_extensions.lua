return {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {
        inlay_hints = {
            inline = true,
        },
    },
    keys = {
        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "C/C++: Switch Source/Header" },
        { "<leader>cT", "<cmd>ClangdTypeHierarchy<cr>", desc = "C/C++: Type Hierarchy" },
    },
}
