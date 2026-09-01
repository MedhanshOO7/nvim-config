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
                    local file_dir = vim.fn.expand("%:p:h")
                    local venv = vim.env.VIRTUAL_ENV
                    if not venv or venv == "" then
                        local found = vim.fs.find({ ".venv", "venv" }, { upward = true, path = file_dir })[1]
                        if found then
                            venv = vim.fn.fnamemodify(found, ":p"):gsub("[/\\]$", "")
                        end
                    end
                    if venv and vim.fn.executable(venv .. "/" .. venv_bin) == 1 then
                        py_bin = venv .. "/" .. venv_bin
                    end
                    return string.format("%s -u", vim.fn.shellescape(py_bin))
                end,
                typescript = "deno run --allow-all",
                javascript = "node",
                rust = is_win and { "cd $dir &&", "rustc $fileName &&", "$dir\\$fileNameWithoutExt.exe" }
                    or { "cd $dir &&", "rustc $fileName &&", "$dir/$fileNameWithoutExt" },
                c = is_win and { "cd $dir &&", "gcc $fileName -o $fileNameWithoutExt.exe &&", "$dir\\$fileNameWithoutExt.exe" }
                    or { "cd $dir &&", "gcc $fileName -o /tmp/$fileNameWithoutExt &&", "/tmp/$fileNameWithoutExt" },
                cpp = is_win and { "cd $dir &&", "g++ -std=c++20 $fileName -o $fileNameWithoutExt.exe &&", "$dir\\$fileNameWithoutExt.exe" }
                    or { "cd $dir &&", "g++ -std=c++20 $fileName -o /tmp/$fileNameWithoutExt &&", "/tmp/$fileNameWithoutExt" },
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
