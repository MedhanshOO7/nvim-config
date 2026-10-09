return {
    {
        "mason-org/mason.nvim",
        event = "VeryLazy",
        opts = {
            ui = {
                border = "rounded",
                width = 0.8,
                height = 0.8,
                icons = {
                    package_installed = " ",
                    package_pending = " ",
                    package_uninstalled = " ",
                },
            },
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "BufReadPre",
        dependencies = {
            {
                "mason-org/mason.nvim",
                opts = {},
            },
        },
        opts = {
            -- Debuggers, formatters and linters only; LSP servers are installed
            -- by mason-lspconfig in lua/plugins/lsp.lua
            ensure_installed = {
                "debugpy",
                "codelldb",
                "clang-format",
                "eslint_d",
                "js-debug-adapter",
                "markdownlint",
                "prettierd",
                "prettier",
                "ruff",
                "selene",
                "shellcheck",
                "shfmt",
                "sql-formatter",
                "stylua",
            },
        },
    },
}
