return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local lualine_group = vim.api.nvim_create_augroup("dynamic_lualine_theme", { clear = true })

        local function to_hex(value)
            if type(value) == "number" then
                return string.format("#%06x", value)
            end
            return value
        end

        local function hex_to_rgb(hex)
            hex = to_hex(hex)
            if type(hex) ~= "string" then hex = "#1e1e2e" end
            hex = hex:gsub("#", "")
            if hex == "" or hex:lower() == "none" then
                hex = "1e1e2e"
            elseif #hex == 3 then
                hex = hex:gsub(".", "%1%1")
            elseif #hex < 6 then
                hex = hex .. string.rep("0", 6 - #hex)
            elseif #hex > 6 then
                hex = hex:sub(1, 6)
            end
            local r = tonumber(hex:sub(1, 2), 16) or 30
            local g = tonumber(hex:sub(3, 4), 16) or 30
            local b = tonumber(hex:sub(5, 6), 16) or 46
            return r, g, b
        end

        local function blend(fg, bg, alpha)
            local fr, fg_green, fb = hex_to_rgb(fg)
            local br, bg_green, bb = hex_to_rgb(bg)
            alpha = math.max(0, math.min(alpha or 0, 1))
            local function channel(top, bottom)
                return math.floor((alpha * top) + ((1 - alpha) * bottom) + 0.5)
            end
            return string.format("#%02x%02x%02x", channel(fr, br), channel(fg_green, bg_green), channel(fb, bb))
        end

        local function macro_recording()
            local reg = vim.fn.reg_recording()
            if reg == "" then return "" end
            return "󰑋 REC @" .. reg
        end

        local function copilot_status()
            local ok, client = pcall(require, "copilot.client")
            if not ok or client.is_disabled() then return "" end
            return "󰚩 Ready"
        end

        local function lsp_status()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
                return ""
            end
            local names = {}
            for _, client in ipairs(clients) do
                if client.name ~= "copilot" then
                    table.insert(names, client.name)
                end
            end
            if #names == 0 then
                return ""
            end
            return " " .. table.concat(names, ", ")
        end

        local function hl_hex(name, key, default)
            local ok, val = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and val and val[key] then
                return string.format("#%06x", val[key])
            end
            return default
        end

        local function get_floating_theme()
            local bg_dark = "NONE"
            local normal_bg = hl_hex("Normal", "bg", "#1e1e2e")
            local fg_text = hl_hex("Normal", "fg", "#cdd6f4")
            local fg_muted = hl_hex("Comment", "fg", "#6c7086")

            local blue = hl_hex("Function", "fg", "#89b4fa")
            local green = hl_hex("String", "fg", "#a6e3a1")
            local yellow = hl_hex("DiagnosticWarn", "fg", "#f9e2af")
            local purple = hl_hex("Statement", "fg", "#cba6f7")
            local red = hl_hex("DiagnosticError", "fg", "#f38ba8")
            local cyan = hl_hex("Type", "fg", "#89dceb")

            local inactive_bg = blend(fg_text, normal_bg, 0.15)

            return {
                normal = {
                    a = { fg = blue, bg = blend(blue, normal_bg, 0.45), gui = "bold" },
                    b = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = cyan, bg = blend(cyan, normal_bg, 0.45), gui = "bold" },
                    z = { fg = blue, bg = blend(blue, normal_bg, 0.45), gui = "bold" },
                },
                insert = {
                    a = { fg = green, bg = blend(green, normal_bg, 0.45), gui = "bold" },
                    b = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = cyan, bg = blend(cyan, normal_bg, 0.45), gui = "bold" },
                    z = { fg = green, bg = blend(green, normal_bg, 0.45), gui = "bold" },
                },
                visual = {
                    a = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                    b = { fg = blue, bg = blend(blue, normal_bg, 0.45), gui = "bold" },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = cyan, bg = blend(cyan, normal_bg, 0.45), gui = "bold" },
                    z = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                },
                replace = {
                    a = { fg = red, bg = blend(red, normal_bg, 0.45), gui = "bold" },
                    b = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = cyan, bg = blend(cyan, normal_bg, 0.45), gui = "bold" },
                    z = { fg = red, bg = blend(red, normal_bg, 0.45), gui = "bold" },
                },
                command = {
                    a = { fg = yellow, bg = blend(yellow, normal_bg, 0.45), gui = "bold" },
                    b = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = cyan, bg = blend(cyan, normal_bg, 0.45), gui = "bold" },
                    z = { fg = yellow, bg = blend(yellow, normal_bg, 0.45), gui = "bold" },
                },
                inactive = {
                    a = { fg = fg_muted, bg = inactive_bg },
                    b = { fg = fg_muted, bg = inactive_bg },
                    c = { fg = fg_muted, bg = bg_dark },
                    x = { fg = fg_muted, bg = bg_dark },
                    y = { fg = fg_muted, bg = inactive_bg },
                    z = { fg = fg_muted, bg = inactive_bg },
                },
            }
        end

        local function apply()
            local theme = get_floating_theme()
            local normal_bg = hl_hex("Normal", "bg", "#1e1e2e")
            local blue = hl_hex("Function", "fg", "#89b4fa")
            local green = hl_hex("String", "fg", "#a6e3a1")
            local purple = hl_hex("Statement", "fg", "#cba6f7")
            local peach = hl_hex("DiagnosticWarn", "fg", "#fab387")
            local red = hl_hex("DiagnosticError", "fg", "#f38ba8")
            local cyan = hl_hex("Type", "fg", "#89dceb")
            local lavender = hl_hex("Special", "fg", "#b4befe")

            vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

            require("lualine").setup({
                options = {
                    theme = theme,
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                    always_divide_middle = true,
                    disabled_filetypes = {
                        statusline = { "snacks_picker_input", "snacks_explorer", "noice", "nui", "notify", "prompt", "lazy", "mason" },
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            separator = { left = "", right = "" },
                            padding = { left = 1, right = 1 },
                            fmt = function(mode_name)
                                local mode_map = {
                                    ["NORMAL"] = "󰮯 NORMAL",
                                    ["O-PENDING"] = "󰮯 OP",
                                    ["INSERT"] = "󰏫 INSERT",
                                    ["VISUAL"] = "󰈈 VISUAL",
                                    ["V-LINE"] = "󰈈 V-LINE",
                                    ["V-BLOCK"] = "󰈈 V-BLOCK",
                                    ["SELECT"] = "󰒆 SELECT",
                                    ["S-LINE"] = "󰒆 S-LINE",
                                    ["S-BLOCK"] = "󰒆 S-BLOCK",
                                    ["REPLACE"] = "󰅪 REPLACE",
                                    ["V-REPLACE"] = "󰅪 V-REP",
                                    ["COMMAND"] = "󰘳 COMMAND",
                                    ["EX"] = "󰘳 EX",
                                    ["MORE"] = "󰘳 MORE",
                                    ["CONFIRM"] = "󰘳 CONFIRM",
                                    ["SHELL"] = "󰚌 SHELL",
                                    ["TERMINAL"] = "󰚌 TERM",
                                }
                                return mode_map[mode_name] or mode_name
                            end,
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                            color = { fg = purple, bg = blend(purple, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            color = { fg = lavender, bg = blend(lavender, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 1,
                            symbols = {
                                modified = " ●",
                                readonly = " 󰌾",
                                unnamed = "[No Name]",
                                newfile = "[New]",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            macro_recording,
                            color = { fg = red, bg = blend(red, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            copilot_status,
                            color = { fg = green, bg = blend(green, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            color = { fg = peach, bg = blend(peach, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            lsp_status,
                            color = { fg = blue, bg = blend(blue, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        {
                            "filetype",
                            icon_only = false,
                            color = { fg = cyan, bg = blend(cyan, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "progress",
                            color = { fg = lavender, bg = blend(lavender, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            icon = "",
                            color = { fg = blue, bg = blend(blue, normal_bg, 0.45), gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = { "trouble", "quickfix", "toggleterm", "lazy", "mason" },
            })
        end

        apply()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = lualine_group,
            callback = function()
                vim.schedule(apply)
            end,
        })
    end,
}
