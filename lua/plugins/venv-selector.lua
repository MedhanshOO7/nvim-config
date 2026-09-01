return {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap-python",
    },
    branch = "regexp",
    opts = {
        settings = {
            options = {
                notify_user_on_venv_activation = true,
            },
        },
    },
    config = function(_, opts)
        require("venv-selector").setup(opts)

        -- Automatically activate .venv (uv style) like VS Code
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            callback = function()
                local venv = vim.fn.finddir(".venv", vim.fn.getcwd() .. ";")
                if venv ~= "" then
                    local venv_path = vim.fn.fnamemodify(venv, ":p"):gsub("[/\\]$", "")
                    -- If not already active
                    if vim.env.VIRTUAL_ENV ~= venv_path then
                        local is_win = vim.fn.has("win32") == 1
                        local bin_dir = is_win and (venv_path .. "\\Scripts") or (venv_path .. "/bin")
                        local sep = is_win and ";" or ":"
                        vim.env.VIRTUAL_ENV = venv_path
                        vim.env.PATH = bin_dir .. sep .. vim.env.PATH
                        vim.notify("Auto-activated venv: " .. venv_path, vim.log.levels.INFO, { title = "Python" })
                        -- Restart LSPs to pick up the new environment
                        pcall(vim.cmd, "LspRestart basedpyright")
                    end
                end
            end,
        })
    end,
    keys = {
        { "<leader>Pv", "<cmd>VenvSelect<cr>", desc = "Python: Select VirtualEnv" },
        { "<leader>Pc", "<cmd>VenvSelectCached<cr>", desc = "Python: Select Cached VirtualEnv" },
        { "<leader>Pm", function()
            local venv_name = vim.fn.input("Venv Name (default: .venv): ")
            if venv_name == "" then venv_name = ".venv" end
            local cmd = ""
            if vim.fn.executable("uv") == 1 then
                cmd = "uv venv " .. venv_name
            else
                cmd = "python3 -m venv " .. venv_name
            end
            vim.notify("Creating venv with: " .. cmd, vim.log.levels.INFO)
            vim.fn.system(cmd)
            if vim.v.shell_error == 0 then
                vim.notify("Virtual environment '" .. venv_name .. "' created successfully!", vim.log.levels.INFO)
                vim.cmd("VenvSelect")
            else
                vim.notify("Failed to create virtual environment", vim.log.levels.ERROR)
            end
        end, desc = "Python: Make VirtualEnv" },
        { "<leader>Pi", function()
            local pkg = vim.fn.input("Install Python package: ")
            if pkg == "" then return end
            local pip_cmd = "pip install"
            if vim.fn.executable("uv") == 1 then
                pip_cmd = "uv pip install"
            elseif vim.env.VIRTUAL_ENV and vim.fn.executable(vim.env.VIRTUAL_ENV .. "/bin/pip") == 1 then
                pip_cmd = vim.env.VIRTUAL_ENV .. "/bin/pip install"
            end
            local full_cmd = pip_cmd .. " " .. pkg
            vim.notify("Installing: " .. pkg .. " ...", vim.log.levels.INFO, { title = "Python" })
            vim.fn.jobstart(full_cmd, {
                on_exit = function(_, code)
                    if code == 0 then
                        vim.notify("Successfully installed: " .. pkg .. " ", vim.log.levels.INFO, { title = "Python" })
                        pcall(vim.cmd, "LspRestart basedpyright")
                    else
                        vim.notify("Failed to install: " .. pkg .. " ", vim.log.levels.ERROR, { title = "Python" })
                    end
                end,
            })
        end, desc = "Python: Install package" },
        { "<leader>PR", function()
            local req_file = vim.fn.findfile("requirements.txt", ".;")
            if req_file == "" then
                vim.notify("No requirements.txt found in project root", vim.log.levels.WARN, { title = "Python" })
                return
            end
            local cmd = (vim.fn.executable("uv") == 1 and "uv pip install -r " or "pip install -r ") .. req_file
            vim.notify("Installing dependencies from " .. req_file .. " ...", vim.log.levels.INFO, { title = "Python" })
            vim.fn.jobstart(cmd, {
                on_exit = function(_, code)
                    if code == 0 then
                        vim.notify("Successfully installed requirements! ", vim.log.levels.INFO, { title = "Python" })
                        pcall(vim.cmd, "LspRestart basedpyright")
                    else
                        vim.notify("Failed to install requirements ", vim.log.levels.ERROR, { title = "Python" })
                    end
                end,
            })
        end, desc = "Python: Install requirements.txt" },
        { "<leader>Pr", function()
            vim.cmd("RunFile")
        end, desc = "Python: Run current file" },
    },
}
