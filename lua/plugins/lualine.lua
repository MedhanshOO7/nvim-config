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

        -- Dynamically extracts all palette colors from whichever theme is active
        local function get_theme_palette()
            local normal_bg = hl_hex("Normal", "bg", hl_hex("NormalFloat", "bg", "#1e1e2e"))
            local normal_fg = hl_hex("Normal", "fg", hl_hex("NormalFloat", "fg", "#cdd6f4"))
            local comment   = hl_hex("Comment", "fg", "#6c7086")

            local blue      = hl_hex("Function", "fg", hl_hex("Directory", "fg", "#89b4fa"))
            local green     = hl_hex("String", "fg", hl_hex("DiagnosticOk", "fg", "#a6e3a1"))
            local yellow    = hl_hex("DiagnosticWarn", "fg", hl_hex("Constant", "fg", "#f9e2af"))
            local purple    = hl_hex("Statement", "fg", hl_hex("Keyword", "fg", "#cba6f7"))
            local red       = hl_hex("DiagnosticError", "fg", hl_hex("Error", "fg", "#f38ba8"))
            local cyan      = hl_hex("Type", "fg", hl_hex("Special", "fg", "#89dceb"))
            local teal      = hl_hex("SpecialChar", "fg", hl_hex("Special", "fg", "#94e2d5"))
            local lavender  = hl_hex("Identifier", "fg", hl_hex("PreProc", "fg", "#b4befe"))
            local peach     = hl_hex("DiagnosticWarn", "fg", hl_hex("Number", "fg", "#fab387"))

            return {
                normal_bg = normal_bg,
                normal_fg = normal_fg,
                comment   = comment,
                blue      = blue,
                green     = green,
                yellow    = yellow,
                purple    = purple,
                red       = red,
                cyan      = cyan,
                teal      = teal,
                lavender  = lavender,
                peach     = peach,
            }
        end

        local function contrast_fg(bg_color)
            local p = get_theme_palette()
            local r, g, b = hex_to_rgb(bg_color)
            local lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
            if lum > 0.36 then
                return p.normal_bg ~= "NONE" and p.normal_bg or "#181825"
            else
                return p.normal_fg ~= "NONE" and p.normal_fg or "#cdd6f4"
            end
        end

        local function get_floating_theme()
            local p = get_theme_palette()
            local bg_dark = "NONE"

            local norm_bg   = blend(p.blue, p.normal_bg, 0.60)
            local ins_bg    = blend(p.green, p.normal_bg, 0.60)
            local vis_bg    = blend(p.purple, p.normal_bg, 0.60)
            local rep_bg    = blend(p.red, p.normal_bg, 0.60)
            local cmd_bg    = blend(p.yellow, p.normal_bg, 0.60)
            local pill_b_bg = blend(p.purple, p.normal_bg, 0.60)
            local pill_y_bg = blend(p.cyan, p.normal_bg, 0.60)
            local inact_bg  = blend(p.normal_fg, p.normal_bg, 0.15)

            return {
                normal = {
                    a = { fg = contrast_fg(norm_bg), bg = norm_bg, gui = "bold" },
                    b = { fg = contrast_fg(pill_b_bg), bg = pill_b_bg, gui = "bold" },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = contrast_fg(pill_y_bg), bg = pill_y_bg, gui = "bold" },
                    z = { fg = contrast_fg(norm_bg), bg = norm_bg, gui = "bold" },
                },
                insert = {
                    a = { fg = contrast_fg(ins_bg), bg = ins_bg, gui = "bold" },
                    b = { fg = contrast_fg(pill_b_bg), bg = pill_b_bg, gui = "bold" },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = contrast_fg(pill_y_bg), bg = pill_y_bg, gui = "bold" },
                    z = { fg = contrast_fg(ins_bg), bg = ins_bg, gui = "bold" },
                },
                visual = {
                    a = { fg = contrast_fg(vis_bg), bg = vis_bg, gui = "bold" },
                    b = { fg = contrast_fg(norm_bg), bg = norm_bg, gui = "bold" },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = contrast_fg(pill_y_bg), bg = pill_y_bg, gui = "bold" },
                    z = { fg = contrast_fg(vis_bg), bg = vis_bg, gui = "bold" },
                },
                replace = {
                    a = { fg = contrast_fg(rep_bg), bg = rep_bg, gui = "bold" },
                    b = { fg = contrast_fg(pill_b_bg), bg = pill_b_bg, gui = "bold" },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = contrast_fg(pill_y_bg), bg = pill_y_bg, gui = "bold" },
                    z = { fg = contrast_fg(rep_bg), bg = rep_bg, gui = "bold" },
                },
                command = {
                    a = { fg = contrast_fg(cmd_bg), bg = cmd_bg, gui = "bold" },
                    b = { fg = contrast_fg(pill_b_bg), bg = pill_b_bg, gui = "bold" },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = contrast_fg(pill_y_bg), bg = pill_y_bg, gui = "bold" },
                    z = { fg = contrast_fg(cmd_bg), bg = cmd_bg, gui = "bold" },
                },
                inactive = {
                    a = { fg = p.comment, bg = inact_bg },
                    b = { fg = p.comment, bg = inact_bg },
                    c = { fg = p.comment, bg = bg_dark },
                    x = { fg = p.comment, bg = bg_dark },
                    y = { fg = p.comment, bg = inact_bg },
                    z = { fg = p.comment, bg = inact_bg },
                },
            }
        end

        local function apply()
            local theme = get_floating_theme()

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
                            color = function()
                                local p = get_theme_palette()
                                local git = vim.b.gitsigns_status_dict
                                local is_clean = git and (git.added or 0) == 0 and (git.changed or 0) == 0 and (git.removed or 0) == 0
                                local branch_accent = is_clean and p.green or p.peach
                                local branch_bg = blend(branch_accent, p.normal_bg, 0.60)
                                return { fg = contrast_fg(branch_bg), bg = branch_bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            color = function()
                                local p = get_theme_palette()
                                local bg = blend(p.purple, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 4,
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
                            color = function()
                                local p = get_theme_palette()
                                local bg = blend(p.red, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            copilot_status,
                            color = function()
                                local p = get_theme_palette()
                                local bg = blend(p.teal, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            color = function()
                                local p = get_theme_palette()
                                local bg = blend(p.peach, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            lsp_status,
                            color = function()
                                local p = get_theme_palette()
                                local bg = blend(p.lavender, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        {
                            "filetype",
                            icon_only = false,
                            color = function()
                                local p = get_theme_palette()
                                local bg = blend(p.cyan, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            icon = "",
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
            pattern = "*",
            callback = apply,
        })
    end,
}
