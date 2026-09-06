return {
    "folke/noice.nvim",
    event = "VeryLazy",

    dependencies = {
        "MunifTanjim/nui.nvim",
        "folke/snacks.nvim",
    },

    config = function()
        require("noice").setup({
            -- ============================================================
            -- Command Line
            -- ============================================================
            cmdline = {
                enabled = true,
                view = "cmdline_popup",

                format = {
                    cmdline = {
                        icon = " ",
                        hl_group = "Function",
                    },

                    search_down = {
                        icon = "  ",
                        hl_group = "DiagnosticWarn",
                    },

                    search_up = {
                        icon = "  ",
                        hl_group = "DiagnosticWarn",
                    },

                    filter = {
                        icon = "$ ",
                        hl_group = "DiagnosticInfo",
                    },

                    lua = {
                        icon = " ",
                        hl_group = "Special",
                    },

                    help = {
                        icon = "󰋖 ",
                        hl_group = "DiagnosticHint",
                    },

                    input = {
                        icon = "󰥻 ",
                        hl_group = "Title",
                    },
                },
            },

            -- ============================================================
            -- Messages / Command Output
            -- ============================================================
            messages = {
                enabled = true,

                -- Normal messages become floating notifications.
                view = "notify",

                -- Errors / warnings use the same notification system.
                view_error = "notify",
                view_warn = "notify",

                -- Keep message history accessible through Noice.
                view_history = "messages",
            },

            -- ============================================================
            -- Notifications
            -- ============================================================
            notify = {
                enabled = true,

                view = "notify",

                -- Keep notifications compact.
                merge = true,
            },

            -- ============================================================
            -- Popup Menu
            -- ============================================================
            popupmenu = {
                enabled = false,
            },

            -- ============================================================
            -- LSP
            -- ============================================================
            lsp = {
                progress = {
                    enabled = true,
                },

                hover = {
                    enabled = true,
                    view = nil,
                },

                signature = {
                    enabled = true,

                    auto_open = {
                        enabled = false,
                        trigger = true,
                        luasnip = true,
                        throttle = 50,
                    },

                    view = nil,

                    opts = {
                        max_width = math.max(40, math.floor(vim.o.columns * 0.45)),

                        max_height = math.max(4, math.floor(vim.o.lines * 0.18)),
                    },
                },

                message = {
                    enabled = true,
                },
            },

            -- ============================================================
            -- Views
            -- ============================================================
            views = {
                -- --------------------------------------------------------
                -- Main command line
                -- --------------------------------------------------------
                cmdline_popup = {
                    position = {
                        row = "40%",
                        col = "50%",
                    },

                    size = {
                        min_width = 60,
                        width = "auto",
                        max_width = math.floor(vim.o.columns * 0.75),
                        height = "auto",
                    },

                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },

                    win_options = {
                        winhighlight = table.concat({
                            "Normal:NoiceCmdlinePopup",
                            "FloatBorder:NoiceCmdlinePopupBorder",
                            "FloatTitle:NoiceCmdlinePopupTitle",
                        }, ","),

                        wrap = true,
                        linebreak = true,
                        sidescrolloff = 0,
                        cursorline = false,
                        foldenable = false,
                    },
                },

                -- --------------------------------------------------------
                -- Messages
                -- --------------------------------------------------------
                messages = {
                    position = {
                        row = "20%",
                        col = "50%",
                    },

                    size = {
                        min_width = 60,
                        width = "auto",
                        max_width = math.floor(vim.o.columns * 0.75),
                        height = "auto",
                    },

                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },

                    win_options = {
                        wrap = true,
                        linebreak = true,
                        sidescrolloff = 0,
                        cursorline = false,
                        foldenable = false,

                        winhighlight = table.concat({
                            "Normal:NoicePopup",
                            "FloatBorder:NoicePopupBorder",
                            "FloatTitle:NoicePopupTitle",
                        }, ","),
                    },
                },
            },

            -- ============================================================
            -- Presets
            -- ============================================================
            presets = {
                -- Centered search instead of bottom command-line search.
                bottom_search = false,

                -- We use our own command-line styling.
                command_palette = false,

                -- Long output should remain readable.
                long_message_to_split = true,

                inc_rename = false,

                -- LSP documentation gets a border.
                lsp_doc_border = true,
            },

            -- ============================================================
            -- Routes
            -- ============================================================
            routes = {
                -- Ignore noisy messages that don't provide useful
                -- information to the user.
                {
                    filter = {
                        event = "msg_show",

                        any = {
                            {
                                find = "Terminal did not respond to DSR request",
                            },

                            {
                                find = "E1568",
                            },

                            {
                                find = "is_stopped is deprecated",
                            },

                            {
                                find = "client.request is deprecated",
                            },

                            {
                                find = "written",
                            },
                        },
                    },

                    opts = {
                        skip = true,
                    },
                },
            },
        })
    end,
}
