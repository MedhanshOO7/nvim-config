return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",

        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },

        config = function()
            ----------------------------------------------------------------------
            -- nvim-notify
            --
            -- IMPORTANT:
            -- Noice remains the notification manager.
            -- nvim-notify is only the renderer used by Noice's `notify` view.
            ----------------------------------------------------------------------

            local notify = require("notify")

notify.setup({
    timeout = 3000,
    minimum_width = 35,
    max_width = function() return math.floor(vim.o.columns * 0.40) end,
    max_height = function() return math.floor(vim.o.lines * 0.60) end,

    render = "default",  -- was "wrapped-compact"

    top_down = true,
    background_colour = "#000000",

    on_open = function(win)
        vim.api.nvim_set_option_value("wrap", true, { win = win })
        vim.api.nvim_set_option_value("linebreak", true, { win = win })
        vim.api.nvim_set_option_value("showbreak", "", { win = win })
    end,
})

            ----------------------------------------------------------------------
            -- Noice
            ----------------------------------------------------------------------

            require("noice").setup({
                ------------------------------------------------------------------
                -- Command line
                ------------------------------------------------------------------

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


                ------------------------------------------------------------------
                -- Messages
                ------------------------------------------------------------------

                messages = {
                    enabled = true,

                    -- Normal command/message output
                    view = "notify",

                    -- Errors and warnings should use the same notification UI.
                    view_error = "notify",
                    view_warn = "notify",

                    -- Keep complete history accessible through :Noice.
                    view_history = "messages",

                    -- Search counts are better kept as virtual text.
                    view_search = "virtualtext",
                },


                ------------------------------------------------------------------
                -- Popup menu
                --
                -- Keep disabled because your setup isn't using Noice's
                -- completion popup.
                ------------------------------------------------------------------

                popupmenu = {
                    enabled = false,
                },


                ------------------------------------------------------------------
                -- vim.notify()
                --
                -- This is the important part.
                --
                -- Plugins calling vim.notify() are intercepted by Noice and
                -- routed through the same notification pipeline.
                ------------------------------------------------------------------

                notify = {
                    enabled = true,
                    view = "notify",
                },


                ------------------------------------------------------------------
                -- LSP
                ------------------------------------------------------------------

                lsp = {
                    progress = {
                        enabled = true,
                        view = "mini",

                        -- Don't update the UI excessively.
                        throttle = 1000 / 30,
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
                            max_width = math.max(
                                40,
                                math.floor(vim.o.columns * 0.45)
                            ),

                            max_height = math.max(
                                4,
                                math.floor(vim.o.lines * 0.18)
                            ),
                        },
                    },

                    message = {
                        enabled = true,
                        view = "notify",
                    },
                },


                ------------------------------------------------------------------
                -- Custom views
                ------------------------------------------------------------------

                views = {
                    ----------------------------------------------------------------
                    -- Your command-line popup
                    ----------------------------------------------------------------

                    cmdline_popup = {
                        position = {
                            row = "40%",
                            col = "50%",
                        },

                        size = {
                            width = "auto",
                            min_width = 40,
                            max_width = 80,
                            height = "auto",
                        },

                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },

                        win_options = {
                            winblend = 0,

                            winhighlight = table.concat({
                                "Normal:NormalFloat",
                                "FloatBorder:FloatBorder",
                                "FloatTitle:FloatTitle",
                            }, ","),

                            wrap = true,
                            linebreak = true,
                        },
                    },

                    ----------------------------------------------------------------
                    -- Input windows use the same visual style.
                    ----------------------------------------------------------------

                    cmdline_input = {
                        view = "cmdline_popup",

                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },
                    },
                },


                ------------------------------------------------------------------
                -- Presets
                ------------------------------------------------------------------

                presets = {
                    -- We don't want the classic bottom search UI.
                    bottom_search = false,

                    -- Keep command line independent from popup completion.
                    command_palette = false,

                    -- Don't automatically throw long messages into a split.
                    --
                    -- This is important because we want our notification
                    -- renderer to handle normal long notifications.
                    long_message_to_split = false,

                    inc_rename = false,

                    -- Rounded LSP documentation borders.
                    lsp_doc_border = true,
                },


                ------------------------------------------------------------------
                -- Routes
                ------------------------------------------------------------------

                routes = {
                    ----------------------------------------------------------------
                    -- Ignore noisy terminal DSR warning.
                    ----------------------------------------------------------------

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

                    ----------------------------------------------------------------
                    -- Long command output:
                    --
                    -- Don't let extremely large output become a gigantic
                    -- notification.
                    --
                    -- Noice's own documentation explicitly supports routing
                    -- messages based on min_height.
                    ----------------------------------------------------------------

                    {
                        filter = {
                            event = "msg_show",
                            min_height = 15,
                        },

                        view = "split",
                    },
                },
            })
        end,
    },
}
