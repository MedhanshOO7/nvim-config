return {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose" },
    keys = {
        { "<leader>rr", "<cmd>RunCode<cr>", desc = "Run: Code block / selection" },
        { "<leader>rf", "<cmd>RunFile<cr>", desc = "Run: Current file" },
        { "<leader>rp", "<cmd>RunProject<cr>", desc = "Run: Project" },
        { "<leader>rc", "<cmd>RunClose<cr>", desc = "Run: Close runner window" },
    },
    opts = {
        mode = "float",
        float = {
            border = "rounded",
            height = 0.8,
            width = 0.8,
            x = 0.5,
            y = 0.5,
            border_hl = "FloatBorder",
            float_hl = "NormalFloat",
        },
        filetype = {
            python = "python3 -u",
            typescript = "deno run --allow-all",
            javascript = "node",
            rust = {
                "cd $dir &&",
                "rustc $fileName &&",
                "$dir/$fileNameWithoutExt",
            },
            c = {
                "cd $dir &&",
                "gcc $fileName -o /tmp/$fileNameWithoutExt &&",
                "/tmp/$fileNameWithoutExt",
            },
            cpp = {
                "cd $dir &&",
                "g++ -std=c++20 $fileName -o /tmp/$fileNameWithoutExt &&",
                "/tmp/$fileNameWithoutExt",
            },
            sh = "bash",
            zsh = "zsh",
            lua = "nvim -l",
            go = "go run",
        },
    },
}
