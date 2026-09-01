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

        return {
            mode = "toggleterm",
            focus = true,
            startinsert = true,
            filetype = {
                python = function()
                    local py_bin = is_win and "python" or "python3"
                    local venv_bin = is_win and "Scripts/python.exe" or "bin/python"

                    if vim.env.VIRTUAL_ENV then
                        local venv_python = vim.env.VIRTUAL_ENV .. "/" .. venv_bin
                        if vim.fn.executable(venv_python) == 1 then
                            py_bin = venv_python
                        end
                    else
                        local local_venv = vim.fn.findfile(".venv/" .. venv_bin, ".;")
                        if local_venv == "" then
                            local_venv = vim.fn.findfile("venv/" .. venv_bin, ".;")
                        end
                        if local_venv ~= "" and vim.fn.executable(local_venv) == 1 then
                            py_bin = vim.fn.fnamemodify(local_venv, ":p")
                        end
                    end

                    return string.format("%s -u", vim.fn.shellescape(py_bin))
                end,
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
                markdown = "report-tool $fileName",
            },
        }
    end,
    config = function(_, opts)
        require("code_runner").setup(opts)
    end,
}
