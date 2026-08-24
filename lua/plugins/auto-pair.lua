return {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = function()
        local autopairs = require("nvim-autopairs")

        autopairs.setup({
            check_ts = true,
            enable_check_bracket_line = false,
            disable_filetype = { "TelescopePrompt", "grug-far", "snacks_picker_input" },
            fast_wrap = {},
            ts_config = {
                lua = { "string" },
                java = false,
            },
        })

        local cmp_ok, cmp = pcall(require, "cmp")
        if cmp_ok then
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    end,
}
