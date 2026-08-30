return {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    enabled = true,
    opts = {
        notification = {
            override_vim_notify = false,
            window = {
                winblend = 0,
            },
        },
        progress = {
            display = {
                done_ttl = 2,
            },
        },
    },
}
