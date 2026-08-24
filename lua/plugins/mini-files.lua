return {
    "echasnovski/mini.files",
    enabled = false, -- snacks.explorer and oil.nvim cover file exploration
    version = false,
    keys = {
        {
            "<leader>fm",
            function()
                local mf = require("mini.files")
                if not mf.close() then
                    mf.open(vim.api.nvim_buf_get_name(0), true)
                end
            end,
            desc = "Find: Mini.files directory browser",
        },
        {
            "<leader>em",
            function()
                local mf = require("mini.files")
                if not mf.close() then
                    mf.open(vim.uv.cwd(), true)
                end
            end,
            desc = "Explorer: Mini.files (cwd)",
        },
    },
    opts = {
        windows = {
            preview = true,
            width_focus = 30,
            width_nofocus = 15,
            width_preview = 50,
        },
        options = {
            use_as_default_explorer = false,
        },
    },
    config = function(_, opts)
        require("mini.files").setup(opts)

        local map_split = function(buf_id, lhs, direction)
            local rhs = function()
                local cur_target = require("mini.files").get_explorer_state().target_window
                local new_target = vim.api.nvim_win_call(cur_target, function()
                    vim.cmd(direction .. " split")
                    return vim.api.nvim_get_current_win()
                end)
                require("mini.files").set_target_window(new_target)
                require("mini.files").go_in({ close_on_file = true })
            end

            local desc = "Open in " .. direction .. " split"
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id
                map_split(buf_id, "<C-s>", "belowright horizontal")
                map_split(buf_id, "<C-v>", "belowright vertical")
            end,
        })
    end,
}
