return {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "nvim-telescope/telescope.nvim",
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
                        vim.cmd("LspRestart pylsp ruff")
                    end
                end
            end,
        })
    end,
    keys = {
        { "<leader>Pv", "<cmd>VenvSelect<cr>", desc = "Python: Select VirtualEnv" },
        { "<leader>Pc", "<cmd>VenvSelectCached<cr>", desc = "Python: Select Cached VirtualEnv" },
    },
}
