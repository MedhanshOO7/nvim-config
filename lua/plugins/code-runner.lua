return {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose" },
    keys = {
        { "<leader>rr", "<cmd>RunCode<cr>", desc = "Run: Code block / selection" },
        { "<leader>rf", "<cmd>RunFile<cr>", desc = "Run: Current file" },
        { "<leader>rp", "<cmd>RunProject<cr>", desc = "Run: Project" },
        { "<leader>rc", "<cmd>RunClose<cr>", desc = "Run: Close runner window" },
    },
    opts = function()
        local is_win = vim.fn.has("win32") == 1
        local python_cmd = (vim.fn.executable("python3") == 1 and "python3 -u") or "python -u"

        return {
            mode = "toggleterm",
            focus = true,
            startinsert = true,
            filetype = {
                python = python_cmd,
                typescript = "deno run --allow-all",
                javascript = "node",
                rust = is_win and {
                    "cd $dir &&",
                    "rustc $fileName &&",
                    "$dir\\$fileNameWithoutExt.exe",
                } or {
                    "cd $dir &&",
                    "rustc $fileName &&",
                    "$dir/$fileNameWithoutExt",
                },
                c = is_win and {
                    "cd $dir &&",
                    "gcc $fileName -o $fileNameWithoutExt.exe &&",
                    "$dir\\$fileNameWithoutExt.exe",
                } or {
                    "cd $dir &&",
                    "gcc $fileName -o /tmp/$fileNameWithoutExt &&",
                    "/tmp/$fileNameWithoutExt",
                },
                cpp = is_win and {
                    "cd $dir &&",
                    "g++ -std=c++20 $fileName -o $fileNameWithoutExt.exe &&",
                    "$dir\\$fileNameWithoutExt.exe",
                } or {
                    "cd $dir &&",
                    "g++ -std=c++20 $fileName -o /tmp/$fileNameWithoutExt &&",
                    "/tmp/$fileNameWithoutExt",
                },
                sh = "bash",
                zsh = "zsh",
                ps1 = "powershell -ExecutionPolicy Bypass -File",
                bat = "cmd /c",
                cmd = "cmd /c",
                lua = "nvim -l",
                go = "go run",
            },
<<<<<<< HEAD
        }
    end,
||||||| parent of aced673 (feat(markdown): add report-tool integration, keymaps, runner, and snippets)
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
=======
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
            markdown = "report-tool $fileName",
        },
    },
>>>>>>> aced673 (feat(markdown): add report-tool integration, keymaps, runner, and snippets)
    config = function(_, opts)
        require("code_runner").setup(opts)
    end,
}
