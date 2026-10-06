return {
    "nvim-lualine/lualine.nvim",

    event = "VeryLazy",
    cmd = { "StatusStyle", "UISeparator" },

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    config = function()
        local status_style = require("utils.status_style")

        ----------------------------------------------------------------------
        -- Autocmd group
        ----------------------------------------------------------------------

        local lualine_group = vim.api.nvim_create_augroup(
            "dynamic_lualine_theme",
            { clear = true }
        )

        ----------------------------------------------------------------------
        -- Helpers
        ----------------------------------------------------------------------

        local function glyph(codepoint)
            return vim.fn.nr2char(codepoint)
        end

        local function hl_hex(name, key)
            local ok, value = pcall(vim.api.nvim_get_hl, 0, {
                name = name,
                link = false,
            })

            if ok and value and value[key] then
                return string.format("#%06x", value[key])
            end

            return nil
        end

        local function first_hl(groups, key, fallback)
            for _, group in ipairs(groups) do
                local value = hl_hex(group, key)

                if value then
                    return value
                end
            end

            return fallback
        end

        local function to_hex(value)
            if type(value) == "number" then
                return string.format("#%06x", value)
            end

            return value
        end

        local function hex_to_rgb(hex)
            hex = to_hex(hex)

            if type(hex) ~= "string" then
                return 30, 30, 46
            end

            if hex == "NONE" then
                return 30, 30, 46
            end

            hex = hex:gsub("#", "")

            if #hex == 3 then
                hex = hex:gsub(".", "%1%1")
            end

            if not hex:match("^%x%x%x%x%x%x$") then
                return 30, 30, 46
            end

            return tonumber(hex:sub(1, 2), 16) or 30,
                tonumber(hex:sub(3, 4), 16) or 30,
                tonumber(hex:sub(5, 6), 16) or 46
        end

        local function blend(fg, bg, alpha)
            if fg == "NONE" then
                return bg
            end

            if bg == "NONE" then
                return "NONE"
            end

            local fr, fgr, fb = hex_to_rgb(fg)
            local br, bgr, bb = hex_to_rgb(bg)

            alpha = math.max(0, math.min(alpha or 0, 1))

            local function channel(top, bottom)
                return math.floor(
                    top * alpha + bottom * (1 - alpha) + 0.5
                )
            end

            return string.format(
                "#%02x%02x%02x",
                channel(fr, br),
                channel(fgr, bgr),
                channel(fb, bb)
            )
        end

        ----------------------------------------------------------------------
        -- IMPORTANT:
        -- Preserve transparent Normal backgrounds.
        ----------------------------------------------------------------------

        local function get_normal_bg()
            local bg = hl_hex("Normal", "bg")

            if bg then
                return bg
            end

            bg = hl_hex("NormalFloat", "bg")

            if bg then
                return bg
            end

            return "NONE"
        end

        ----------------------------------------------------------------------
        -- Separators
        ----------------------------------------------------------------------

        local separators = {
            nvchad = {
                default = {
                    left = glyph(0xe0b6),
                    right = glyph(0xe0bc),
                },

                round = {
                    left = glyph(0xe0b6),
                    right = glyph(0xe0b4),
                },

                block = {
                    left = "█",
                    right = "█",
                },

                arrow = {
                    left = glyph(0xe0b2),
                    right = glyph(0xe0b0),
                },
            },

            powerline = {
                left = glyph(0xe0b2),
                right = glyph(0xe0b0),
            },

            powerline_soft = {
                left = glyph(0xe0b3),
                right = glyph(0xe0b1),
            },

            round = {
                left = glyph(0xe0b6),
                right = glyph(0xe0b4),
            },

            slant_right = {
                left = glyph(0xe0ba),
                right = glyph(0xe0b8),
            },

            slant_left = {
                left = glyph(0xe0be),
                right = glyph(0xe0bc),
            },

            none = {
                left = "",
                right = "",
            },
        }

        local function get_nvchad_separator()
            local name = tostring(
                vim.g.ui_nvchad_separator or "round"
            ):lower()

            return separators.nvchad[name]
                or separators.nvchad.round
        end

        ----------------------------------------------------------------------
        -- Icons
        ----------------------------------------------------------------------

        local icons = {
            branch = glyph(0xe0a0),
            location = glyph(0xf041),
            python = glyph(0xe73c),
            lsp = glyph(0xf085),

            diff = {
                added = glyph(0xf457) .. " ",
                modified = glyph(0xf459) .. " ",
                removed = glyph(0xf458) .. " ",
            },

            diag = {
                error = glyph(0xf057) .. " ",
                warn = glyph(0xf071) .. " ",
                info = glyph(0xf05a) .. " ",
                hint = glyph(0xf0eb) .. " ",
            },
        }

        ----------------------------------------------------------------------
        -- Palette
        ----------------------------------------------------------------------

        local cached_palette = nil

        local function get_theme_palette()
            if cached_palette then
                return cached_palette
            end

            cached_palette = {
                normal_bg = get_normal_bg(),

                normal_fg =
                    first_hl(
                        { "Normal", "NormalFloat" },
                        "fg",
                        "#cdd6f4"
                    ),

                comment =
                    first_hl(
                        { "Comment", "LineNr" },
                        "fg",
                        "#6c7086"
                    ),

                blue =
                    first_hl(
                        { "Function", "Directory" },
                        "fg",
                        "#89b4fa"
                    ),

                green =
                    first_hl(
                        { "String", "DiagnosticOk", "GitSignsAdd" },
                        "fg",
                        "#a6e3a1"
                    ),

                yellow =
                    first_hl(
                        { "DiagnosticWarn", "WarningMsg", "Constant" },
                        "fg",
                        "#f9e2af"
                    ),

                purple =
                    first_hl(
                        { "Statement", "Keyword" },
                        "fg",
                        "#cba6f7"
                    ),

                red =
                    first_hl(
                        { "DiagnosticError", "ErrorMsg" },
                        "fg",
                        "#f38ba8"
                    ),

                cyan =
                    first_hl(
                        { "Type", "Special" },
                        "fg",
                        "#89dceb"
                    ),

                teal =
                    first_hl(
                        { "SpecialChar", "Special" },
                        "fg",
                        "#94e2d5"
                    ),

                lavender =
                    first_hl(
                        { "Identifier", "PreProc" },
                        "fg",
                        "#b4befe"
                    ),

                peach =
                    first_hl(
                        { "Number", "DiagnosticWarn" },
                        "fg",
                        "#fab387"
                    ),

                accent =
                    first_hl(
                        { "Function", "Special", "Identifier", "@keyword", "Title" },
                        "fg",
                        "#89b4fa"
                    ),
            }

            return cached_palette
        end

        ----------------------------------------------------------------------
        -- Contrast-aware foreground
        ----------------------------------------------------------------------

        local function contrast_fg(bg)
            local p = get_theme_palette()

            if bg == "NONE" then
                return p.normal_fg
            end

            local r, g, b = hex_to_rgb(bg)

            local luminance =
                (
                    0.2126 * r +
                    0.7152 * g +
                    0.0722 * b
                ) / 255

            if luminance > 0.50 then
                return p.normal_bg == "NONE"
                    and "#000000"
                    or p.normal_bg
            end

            return p.normal_fg
        end

        ----------------------------------------------------------------------
        -- Flat bg helper
        ----------------------------------------------------------------------

        local function flat_bg()
            local p = get_theme_palette()

            return p.normal_bg == "NONE"
                and "#1e1e2e"
                or p.normal_bg
        end

        ----------------------------------------------------------------------
        -- Style registry (30 styles)
        ----------------------------------------------------------------------

        local styles = {
            { id = "nvchad",            name = "NvChad" },
            { id = "lazyvim",           name = "LazyVim" },
            { id = "evil",              name = "Eviline" },
            { id = "frosted",           name = "Frosted Glass (Custom)" },
            { id = "pure_minimal",      name = "Pure Minimal" },
            { id = "powerline",         name = "Classic Powerline" },
            { id = "soft_powerline",    name = "Soft Powerline" },
            { id = "block",             name = "Block" },
            { id = "rounded_pills",     name = "Rounded Pills" },
            { id = "segmented",         name = "Segmented" },
            { id = "airline",           name = "Airline" },
            { id = "helix",             name = "Helix" },
            { id = "doom",              name = "Doom" },
            { id = "retro",             name = "Retro Terminal" },
            { id = "cyberpunk",         name = "Cyberpunk" },
            { id = "glassmorphism",     name = "Glassmorphism" },
            { id = "floating",          name = "Floating" },
            { id = "capsule",           name = "Capsule" },
            { id = "edge",              name = "Edge" },
            { id = "minimal_powerline", name = "Minimal Powerline" },
            { id = "vertical_divider",  name = "Vertical Divider" },
            { id = "bracketed",         name = "Bracketed" },
            { id = "dot_matrix",        name = "Dot Matrix" },
            { id = "dashboard",         name = "Status Dashboard" },
            { id = "zen",               name = "Zen" },
            { id = "split",             name = "Split" },
            { id = "tab_focused",       name = "Tab Focused" },
            { id = "dense",             name = "Dense" },
            { id = "spacious",          name = "Spacious" },
            { id = "editorial",         name = "Editorial" },
        }

        local style_lookup = {}
        local aliases = {}

        for i, s in ipairs(styles) do
            style_lookup[s.id] = s
            aliases[tostring(i)] = s.id
        end

        local function get_style()
            local style = tostring(
                vim.g.lualine_color_style or "frosted"
            ):lower()

            style = aliases[style] or style

            if style_lookup[style] then
                return style
            end

            return "frosted"
        end

        ----------------------------------------------------------------------
        -- Mode
        ----------------------------------------------------------------------

        local mode_icons = {
            ["n"] = "󰮯",
            ["no"] = "󰮯",
            ["v"] = "󰒉",
            ["V"] = "󰒉",
            ["\22"] = "󰒉",
            ["s"] = "󰒉",
            ["S"] = "󰒉",
            ["\19"] = "󰒉",
            ["i"] = "󰏫",
            ["ic"] = "󰏫",
            ["ix"] = "󰏫",
            ["R"] = "󰛔",
            ["Rv"] = "󰛔",
            ["c"] = "󰘳",
            ["cv"] = "󰘳",
            ["ce"] = "󰘳",
            ["r"] = "󰘳",
            ["rm"] = "󰘳",
            ["r?"] = "󰘳",
            ["!"] = "󰘳",
            ["t"] = "󰆍",
        }

        local mode_names = {
            n = "NORMAL",
            no = "NORMAL",
            v = "VISUAL",
            V = "V-LINE",
            ["\22"] = "V-BLOCK",
            s = "SELECT",
            S = "S-LINE",
            ["\19"] = "S-BLOCK",
            i = "INSERT",
            ic = "INSERT",
            ix = "INSERT",
            R = "REPLACE",
            Rv = "V-REPLACE",
            c = "COMMAND",
            cv = "EX",
            ce = "EX",
            r = "REPLACE",
            rm = "MORE",
            ["r?"] = "CONFIRM",
            ["!"] = "SHELL",
            t = "TERMINAL",
        }

        local function get_mode_color()
            local p = get_theme_palette()
            local mode = vim.fn.mode()

            if mode:match("^[iI]") then
                return p.green
            elseif mode:match("^[vVsS\22\19]") then
                return p.purple
            elseif mode:match("^[rR]") then
                return p.red
            elseif mode:match("^[cC!t]") then
                return p.yellow
            end

            return p.blue
        end

        local function format_mode()
            local mode = vim.fn.mode()
            local icon = mode_icons[mode] or "󰮯"
            local name = mode_names[mode] or "NORMAL"

            return icon .. " " .. name
        end

        local function format_evil_mode()
            local mode = vim.fn.mode()

            return mode_icons[mode] or "󰮯"
        end

        local function format_mode_name_only()
            local mode = vim.fn.mode()
            return mode_names[mode] or "NORMAL"
        end

        local function format_mode_icon_only()
            local mode = vim.fn.mode()
            return mode_icons[mode] or "󰮯"
        end

        ----------------------------------------------------------------------
        -- Components
        ----------------------------------------------------------------------

        local function macro_recording()
            local reg = vim.fn.reg_recording()

            if reg == "" then
                return ""
            end

            return "󰑋 REC @" .. reg
        end

        local function git_conflict()
            return vim.b.git_conflict_conflict
                and "󰦖 CONFLICT"
                or ""
        end

        local function buffer_modified()
            return vim.bo.modified and "●" or ""
        end

        local function python_venv()
            if vim.bo.filetype ~= "python" then
                return ""
            end

            local venv = vim.env.VIRTUAL_ENV

            if not venv then
                return icons.python .. " system"
            end

            return icons.python
                .. " "
                .. vim.fn.fnamemodify(venv, ":t")
        end

        local function lsp_progress()
            local ok, status = pcall(vim.lsp.status)

            if not ok or not status or status == "" then
                return ""
            end

            return status
        end

        local function lsp_status()
            local clients = vim.lsp.get_clients({
                bufnr = 0,
            })

            local names = {}

            for _, client in ipairs(clients) do
                if client.name ~= "copilot" then
                    table.insert(names, client.name)
                end
            end

            if #names == 0 then
                return ""
            end

            return icons.lsp
                .. " "
                .. table.concat(names, ", ")
        end

        local function lsp_status_short()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            local count = 0

            for _, client in ipairs(clients) do
                if client.name ~= "copilot" then
                    count = count + 1
                end
            end

            if count == 0 then
                return ""
            end

            return icons.lsp .. " " .. count
        end

        ----------------------------------------------------------------------
        -- Copilot
        ----------------------------------------------------------------------

        local copilot_c
        local copilot_s

        local function get_copilot_state()
            if not package.loaded["copilot.client"] then
                return "hidden"
            end

            if not copilot_c then
                local ok, client =
                    pcall(require, "copilot.client")

                if not ok then
                    return "hidden"
                end

                copilot_c = client
            end

            if copilot_c.is_disabled() then
                return "disabled"
            end

            if copilot_c.startup_error then
                return "issue"
            end

            if not copilot_s then
                local ok, status =
                    pcall(require, "copilot.status")

                if ok then
                    copilot_s = status
                end
            end

            if copilot_s and copilot_s.data then
                local state = string.lower(
                    copilot_s.data.status or ""
                )

                if state == "error"
                    or state == "warning"
                then
                    return "issue"
                end
            end

            if not copilot_c.get() then
                return "disabled"
            end

            return "ready"
        end

        local function copilot_status()
            local state = get_copilot_state()

            if state == "ready" then
                return "󰚩"
            elseif state == "issue" then
                return "󰚩 󰌾"
            end

            return ""
        end

        local function copilot_color()
            local p = get_theme_palette()
            local state = get_copilot_state()

            if state == "disabled" then
                return p.comment
            end

            if state == "issue" then
                return p.yellow
            end

            return p.teal
        end

        ----------------------------------------------------------------------
        -- Disabled filetypes and extensions (shared)
        ----------------------------------------------------------------------

        local disabled_fts = {
            statusline = {
                "snacks_explorer",
                "noice",
                "nui",
                "notify",
                "lazy",
                "mason",
            },
        }

        local extensions = {
            "trouble",
            "quickfix",
            "toggleterm",
            "lazy",
            "mason",
        }

        ----------------------------------------------------------------------
        -- Component builder helper
        --
        -- Safely normalizes strings, functions, and existing tables into
        -- valid flat lualine component tables without illegal table nesting.
        ----------------------------------------------------------------------

        local function make_component(comp, opts)
            local t
            if type(comp) == "table" then
                t = vim.deepcopy(comp)
            else
                t = { comp }
            end
            if opts then
                for k, v in pairs(opts) do
                    t[k] = v
                end
            end
            return t
        end

        ----------------------------------------------------------------------
        -- Pill builders
        ----------------------------------------------------------------------

        local function frosted_pill(comp, accent, alpha)
            local p = get_theme_palette()
            alpha = alpha or 0.08

            local function color()
                local a = type(accent) == "function" and accent() or accent

                if p.normal_bg == "NONE" then
                    return {
                        fg = a,
                        bg = "NONE",
                        gui = "bold",
                    }
                end

                local bg = blend(a, p.normal_bg, alpha)

                return {
                    fg = alpha >= 0.25 and contrast_fg(bg) or a,
                    bg = bg,
                    gui = "bold",
                }
            end

            return make_component(comp, {
                color = color,
                separator = separators.round,
                padding = { left = 1, right = 1 },
            })
        end

        local function solid_pill(comp, fg_color, bg_color, sep)
            return make_component(comp, {
                color = function()
                    local fg = type(fg_color) == "function" and fg_color() or fg_color
                    local bg = type(bg_color) == "function" and bg_color() or bg_color
                    return { fg = fg, bg = bg, gui = "bold" }
                end,
                separator = sep or separators.round,
                padding = { left = 1, right = 1 },
            })
        end

        local function bracket_comp(comp, fg_color)
            local orig_fmt = type(comp) == "table" and comp.fmt or nil
            local function fmt_bracket(s)
                if orig_fmt then
                    s = orig_fmt(s)
                end
                if not s or s == "" then return "" end
                return "[ " .. s .. " ]"
            end

            return make_component(comp, {
                fmt = fmt_bracket,
                color = function()
                    local fg = type(fg_color) == "function" and fg_color() or fg_color
                    return { fg = fg, bg = "NONE" }
                end,
                padding = { left = 0, right = 1 },
            })
        end

        ----------------------------------------------------------------------
        -- Theme builders
        ----------------------------------------------------------------------

        local function make_transparent_theme()
            local p = get_theme_palette()
            local base = {
                a = { fg = p.normal_fg, bg = "NONE" },
                b = { fg = p.normal_fg, bg = "NONE" },
                c = { fg = p.normal_fg, bg = "NONE" },
            }

            local inactive = {
                a = { fg = p.comment, bg = "NONE" },
                b = { fg = p.comment, bg = "NONE" },
                c = { fg = p.comment, bg = "NONE" },
            }

            return {
                normal = vim.deepcopy(base),
                insert = vim.deepcopy(base),
                visual = vim.deepcopy(base),
                replace = vim.deepcopy(base),
                command = vim.deepcopy(base),
                terminal = vim.deepcopy(base),
                inactive = inactive,
            }
        end

        local function make_flat_theme(bg)
            local p = get_theme_palette()
            bg = bg or flat_bg()

            local base = {
                a = { fg = p.normal_fg, bg = bg },
                b = { fg = p.normal_fg, bg = bg },
                c = { fg = p.normal_fg, bg = bg },
                x = { fg = p.normal_fg, bg = bg },
                y = { fg = p.normal_fg, bg = bg },
                z = { fg = p.normal_fg, bg = bg },
            }

            local inactive = {
                a = { fg = p.comment, bg = bg },
                b = { fg = p.comment, bg = bg },
                c = { fg = p.comment, bg = bg },
                x = { fg = p.comment, bg = bg },
                y = { fg = p.comment, bg = bg },
                z = { fg = p.comment, bg = bg },
            }

            return {
                normal = vim.deepcopy(base),
                insert = vim.deepcopy(base),
                visual = vim.deepcopy(base),
                replace = vim.deepcopy(base),
                command = vim.deepcopy(base),
                terminal = vim.deepcopy(base),
                inactive = inactive,
            }
        end

        ----------------------------------------------------------------------
        -- STYLE SETUPS (30 distinct visual designs)
        ----------------------------------------------------------------------

        -- 1. NvChad
        local function setup_nvchad()
            local p = get_theme_palette()
            local sep = get_nvchad_separator()

            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = sep,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component("mode", {
                            fmt = format_mode,
                            color = function()
                                return {
                                    fg = contrast_fg(p.accent),
                                    bg = p.accent,
                                    gui = "bold",
                                }
                            end,
                            separator = sep,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { color = { fg = p.green, bg = "NONE" } }),
                        make_component(macro_recording, { color = { fg = p.red, bg = "NONE" } }),
                    },
                    lualine_c = {
                        make_component("filename", { color = { fg = p.normal_fg, bg = "NONE" } }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { color = { fg = p.yellow, bg = "NONE" } }),
                        make_component("diff", { color = { fg = p.purple, bg = "NONE" } }),
                    },
                    lualine_y = {
                        make_component(lsp_status, { color = { fg = p.lavender, bg = "NONE" } }),
                        make_component(copilot_status, {
                            color = function()
                                return { fg = copilot_color(), bg = "NONE" }
                            end,
                        }),
                    },
                    lualine_z = {
                        make_component("location", {
                            icon = icons.location,
                            color = { fg = p.normal_fg, bg = "NONE" },
                            separator = separators.none,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component("filename", { color = { fg = p.comment, bg = "NONE" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 2. LazyVim
        local function setup_lazyvim()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]", new = "[New]" },
                        },
                        "diagnostics",
                    },
                    lualine_x = { "diff" },
                    lualine_y = { "filetype" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 3. Eviline
        local function setup_eviline()
            local p = get_theme_palette()
            local bg = flat_bg()

            local marker = {
                "▊",
                color = { fg = p.accent, bg = bg },
                padding = { left = 0, right = 0 },
            }

            local evil_mode = {
                format_evil_mode,
                color = function()
                    return { fg = get_mode_color(), bg = bg, gui = "bold" }
                end,
                padding = { left = 1, right = 1 },
            }

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = { marker, evil_mode },
                    lualine_b = { "branch", git_conflict },
                    lualine_c = { "filename" },
                    lualine_x = { "diagnostics", "diff" },
                    lualine_y = { lsp_status },
                    lualine_z = { "location", marker },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "diagnostics", "diff" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 4. Frosted Glass (Custom)
        local function setup_frosted()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        frosted_pill({ "mode", fmt = format_mode }, get_mode_color, 0.35),
                    },
                    lualine_b = {
                        frosted_pill("branch", p.green, 0.08),
                        frosted_pill(git_conflict, p.red, 0.08),
                        frosted_pill("diff", p.purple, 0.08),
                    },
                    lualine_c = {
                        frosted_pill(buffer_modified, p.green, 0.08),
                    },
                    lualine_x = {
                        frosted_pill(macro_recording, p.red, 0.08),
                        frosted_pill(lsp_progress, p.blue, 0.08),
                        frosted_pill(copilot_status, copilot_color, 0.08),
                        frosted_pill("diagnostics", p.peach, 0.08),
                        frosted_pill(lsp_status, p.lavender, 0.08),
                    },
                    lualine_y = {
                        frosted_pill(python_venv, p.green, 0.08),
                        frosted_pill("filetype", p.cyan, 0.08),
                    },
                    lualine_z = {
                        frosted_pill("location", get_mode_color, 0.35),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = { frosted_pill("location", p.comment, 0.08) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 5. Pure Minimal
        local function setup_pure_minimal()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "", right = "" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1 }, { color = { fg = p.normal_fg, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_x = {
                        make_component("filetype", { colored = false, icon_only = false, color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {},
                    lualine_z = {
                        make_component("location", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 6. Classic Powerline
        local function setup_powerline()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.powerline,
                    component_separators = separators.powerline_soft,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        { "mode", fmt = format_mode },
                    },
                    lualine_b = { "branch", "diff" },
                    lualine_c = {
                        { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
                        "diagnostics",
                    },
                    lualine_x = { lsp_status, copilot_status, "encoding" },
                    lualine_y = { "filetype" },
                    lualine_z = { "location", "progress" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 7. Soft Powerline
        local function setup_soft_powerline()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.powerline_soft,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        { "mode", fmt = format_mode_icon_only, padding = { left = 1, right = 1 } },
                    },
                    lualine_b = { "branch" },
                    lualine_c = {
                        { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
                    },
                    lualine_x = { "diagnostics" },
                    lualine_y = { "filetype" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 8. Block
        local function setup_block()
            local p = get_theme_palette()
            local bg = flat_bg()
            local subtle_bg = blend(p.normal_fg, bg, 0.08)

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component({ "mode", fmt = format_mode }, {
                            color = function()
                                local mc = get_mode_color()
                                return { fg = contrast_fg(mc), bg = mc, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { color = { fg = p.green, bg = subtle_bg, gui = "bold" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component("filename", { color = { fg = p.normal_fg, bg = subtle_bg }, padding = { left = 1, right = 1 } }),
                        make_component("diagnostics", { color = { bg = subtle_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_x = {
                        make_component(lsp_status_short, { color = { fg = p.lavender, bg = subtle_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { color = { fg = p.cyan, bg = subtle_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", {
                            color = function()
                                local mc = get_mode_color()
                                return { fg = contrast_fg(mc), bg = mc, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component("filename", { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 9. Rounded Pills
        local function setup_rounded_pills()
            local p = get_theme_palette()

            local function pill(comp, accent_c, strong)
                local a = strong and 0.30 or 0.12
                return make_component(comp, {
                    color = function()
                        local ac = type(accent_c) == "function" and accent_c() or accent_c
                        if p.normal_bg == "NONE" then
                            return { fg = ac, bg = "NONE", gui = strong and "bold" or "" }
                        end
                        local bg = blend(ac, p.normal_bg, a)
                        return {
                            fg = strong and contrast_fg(bg) or ac,
                            bg = bg,
                            gui = strong and "bold" or "",
                        }
                    end,
                    separator = separators.round,
                    padding = { left = 1, right = 1 },
                })
            end

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        pill({ "mode", fmt = format_mode }, get_mode_color, true),
                    },
                    lualine_b = {
                        pill("branch", p.green, false),
                        pill("diff", p.purple, false),
                    },
                    lualine_c = {
                        pill({ "filename", symbols = { modified = " ●" } }, p.blue, false),
                    },
                    lualine_x = {
                        pill("diagnostics", p.peach, false),
                        pill(lsp_status_short, p.lavender, false),
                        pill(copilot_status, copilot_color, false),
                    },
                    lualine_y = {
                        pill("filetype", p.cyan, false),
                    },
                    lualine_z = {
                        pill("location", get_mode_color, true),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { pill("filename", p.comment, false) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 10. Segmented
        local function setup_segmented()
            local p = get_theme_palette()
            local bg = flat_bg()
            local seg_bg = blend(p.normal_fg, bg, 0.06)

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "│", right = "│" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component({ "mode", fmt = format_mode_name_only }, {
                            color = function()
                                return { fg = get_mode_color(), bg = seg_bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { color = { fg = p.green, bg = seg_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component("filename", { color = { fg = p.normal_fg, bg = seg_bg }, padding = { left = 1, right = 1 } }),
                        make_component("diagnostics", { color = { bg = seg_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_x = {
                        make_component("diff", { color = { bg = seg_bg }, padding = { left = 1, right = 1 } }),
                        make_component(lsp_status_short, { color = { fg = p.lavender, bg = seg_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { color = { fg = p.cyan, bg = seg_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = seg_bg, gui = "bold" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component("filename", { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 11. Airline
        local function setup_airline()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.powerline,
                    component_separators = separators.powerline_soft,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component({ "mode", fmt = format_mode }, { padding = { left = 2, right = 2 } }),
                    },
                    lualine_b = {
                        make_component("branch", { padding = { left = 2, right = 2 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●", readonly = " " } }, { padding = { left = 2, right = 2 } }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { padding = { left = 2, right = 2 } }),
                        make_component(lsp_status_short, { color = { fg = p.lavender }, padding = { left = 2, right = 2 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { padding = { left = 2, right = 2 } }),
                    },
                    lualine_z = {
                        make_component("location", { padding = { left = 2, right = 2 } }),
                        make_component("progress", { padding = { left = 1, right = 2 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { padding = { left = 2 } }) },
                    lualine_x = { make_component("location", { padding = { right = 2 } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 12. Helix
        local function setup_helix()
            local p = get_theme_palette()
            local bg = flat_bg()

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component({ "filename", path = 1, symbols = { modified = " [+]", readonly = " [-]" } }, {
                            color = { fg = p.normal_fg, bg = bg },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_c = {},
                    lualine_x = {
                        make_component("diagnostics", { color = { bg = bg }, padding = { left = 1, right = 0 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { colored = false, icon_only = false, color = { fg = p.comment, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 13. Doom
        local function setup_doom()
            local p = get_theme_palette()
            local bg = flat_bg()

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = " ", right = " " },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_icon_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 0 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { icon = icons.branch, color = { fg = p.purple, bg = bg }, padding = { left = 1, right = 1 } }),
                        make_component("diff", { color = { bg = bg }, padding = { left = 0, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●", readonly = " " } }, {
                            color = { fg = p.normal_fg, bg = bg },
                            padding = { left = 1, right = 1 },
                        }),
                        make_component(buffer_modified, { color = { fg = p.green, bg = bg }, padding = { left = 0, right = 0 } }),
                    },
                    lualine_x = {
                        make_component(macro_recording, { color = { fg = p.red, bg = bg }, padding = { left = 1, right = 1 } }),
                        make_component("diagnostics", { color = { bg = bg }, padding = { left = 0, right = 1 } }),
                        make_component(lsp_status_short, { color = { fg = p.lavender, bg = bg }, padding = { left = 0, right = 1 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { colored = false, icon_only = true, color = { fg = p.comment, bg = bg }, padding = { left = 1, right = 0 } }),
                        make_component("encoding", { color = { fg = p.comment, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = bg, gui = "bold" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 14. Retro Terminal
        local function setup_retro()
            local p = get_theme_palette()
            local bg = flat_bg()

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "│", right = "│" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            fmt = function(s) return "[" .. s .. "]" end,
                            color = function()
                                return { fg = get_mode_color(), bg = bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 0 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", {
                            fmt = function(s) return s ~= "" and "git:" .. s or "" end,
                            icon = "",
                            color = { fg = p.green, bg = bg },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = "*", readonly = "[-]" } }, {
                            color = { fg = p.normal_fg, bg = bg },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", {
                            symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
                            color = { bg = bg },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_y = {
                        make_component("filetype", { colored = false, icon_only = false, color = { fg = p.comment, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = bg, gui = "bold" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 15. Cyberpunk
        local function setup_cyberpunk()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.slant_right,
                    component_separators = { left = "╱", right = "╲" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component("mode", {
                            fmt = function() return "▌" .. format_mode_name_only() end,
                            padding = { left = 0, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { padding = { left = 1, right = 1 } }),
                        make_component("diff", { padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ◆", readonly = " ◇" } }, {
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { padding = { left = 1, right = 1 } }),
                        make_component(lsp_status_short, { color = { fg = p.lavender }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", {
                            fmt = function(s) return "▐" .. s end,
                            padding = { left = 0, right = 1 },
                        }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }) },
                    lualine_x = { make_component("location") },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 16. Glassmorphism
        local function setup_glassmorphism()
            local p = get_theme_palette()

            local function glass_pill(comp, accent_c, strong)
                local a = strong and 0.45 or 0.15
                return make_component(comp, {
                    color = function()
                        local ac = type(accent_c) == "function" and accent_c() or accent_c
                        if p.normal_bg == "NONE" then
                            return { fg = ac, bg = "NONE", gui = strong and "bold" or "" }
                        end
                        local bg = blend(ac, p.normal_bg, a)
                        return {
                            fg = strong and contrast_fg(bg) or ac,
                            bg = bg,
                            gui = strong and "bold" or "",
                        }
                    end,
                    separator = separators.round,
                    padding = { left = 2, right = 2 },
                })
            end

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = " ", right = " " },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        glass_pill({ "mode", fmt = format_mode }, get_mode_color, true),
                    },
                    lualine_b = {
                        glass_pill("branch", p.green, false),
                        glass_pill("diff", p.purple, false),
                    },
                    lualine_c = {
                        glass_pill({ "filename", symbols = { modified = " ●" } }, p.blue, false),
                    },
                    lualine_x = {
                        glass_pill("diagnostics", p.peach, false),
                        glass_pill(lsp_status_short, p.lavender, false),
                    },
                    lualine_y = {
                        glass_pill("filetype", p.cyan, false),
                    },
                    lualine_z = {
                        glass_pill("location", get_mode_color, true),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { glass_pill("filename", p.comment, false) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 17. Floating
        local function setup_floating()
            local p = get_theme_palette()

            local function island(comp, accent_c, strong)
                local a = strong and 0.28 or 0.10
                return make_component(comp, {
                    color = function()
                        local ac = type(accent_c) == "function" and accent_c() or accent_c
                        if p.normal_bg == "NONE" then
                            return { fg = ac, bg = "NONE", gui = strong and "bold" or "" }
                        end
                        local bg = blend(ac, p.normal_bg, a)
                        return {
                            fg = strong and contrast_fg(bg) or ac,
                            bg = bg,
                            gui = strong and "bold" or "",
                        }
                    end,
                    separator = separators.round,
                    padding = { left = 1, right = 1 },
                })
            end

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = { left = " ", right = " " },
                    component_separators = { left = "  ", right = "  " },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        island({ "mode", fmt = format_mode_icon_only }, get_mode_color, true),
                    },
                    lualine_b = {
                        island("branch", p.green, false),
                    },
                    lualine_c = {
                        island({ "filename", symbols = { modified = " ●" } }, p.blue, false),
                    },
                    lualine_x = {
                        island("diagnostics", p.peach, false),
                    },
                    lualine_y = {
                        island("filetype", p.cyan, false),
                    },
                    lualine_z = {
                        island("location", get_mode_color, true),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { island("filename", p.comment, false) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 18. Capsule
        local function setup_capsule()
            local p = get_theme_palette()

            local function capsule(comp, accent_c, strong)
                local a = strong and 0.32 or 0.12
                return make_component(comp, {
                    color = function()
                        local ac = type(accent_c) == "function" and accent_c() or accent_c
                        if p.normal_bg == "NONE" then
                            return { fg = ac, bg = "NONE", gui = strong and "bold" or "" }
                        end
                        local bg = blend(ac, p.normal_bg, a)
                        return {
                            fg = strong and contrast_fg(bg) or ac,
                            bg = bg,
                            gui = strong and "bold" or "",
                        }
                    end,
                    separator = separators.round,
                    padding = { left = 2, right = 2 },
                })
            end

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        capsule({ "mode", fmt = format_mode }, get_mode_color, true),
                    },
                    lualine_b = {
                        capsule("branch", p.green, false),
                    },
                    lualine_c = {
                        capsule({ "filename", path = 1, symbols = { modified = " ●" } }, p.blue, false),
                    },
                    lualine_x = {
                        capsule("diagnostics", p.peach, false),
                    },
                    lualine_y = {
                        capsule(lsp_status, p.lavender, false),
                    },
                    lualine_z = {
                        capsule("location", get_mode_color, true),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { capsule("filename", p.comment, false) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 19. Edge
        local function setup_edge()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.powerline,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component({ "mode", fmt = format_mode }, { padding = { left = 2, right = 2 } }),
                    },
                    lualine_b = {},
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.comment },
                            padding = { left = 2, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { color = { fg = p.comment }, padding = { left = 1, right = 2 } }),
                    },
                    lualine_y = {},
                    lualine_z = {
                        make_component("filetype", { padding = { left = 1, right = 1 } }),
                        make_component("location", { padding = { left = 1, right = 2 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }) },
                    lualine_x = { make_component("location") },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 20. Minimal Powerline
        local function setup_minimal_powerline()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.powerline,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_icon_only, {
                            color = function()
                                local mc = get_mode_color()
                                return { fg = contrast_fg(mc), bg = mc, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {},
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.normal_fg, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { color = { bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {},
                    lualine_z = {
                        make_component("location", {
                            color = function()
                                local mc = get_mode_color()
                                return { fg = contrast_fg(mc), bg = mc, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 21. Vertical Divider
        local function setup_vertical_divider()
            local p = get_theme_palette()
            local bg = flat_bg()

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "│", right = "│" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { color = { fg = p.green, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.normal_fg, bg = bg },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { color = { bg = bg }, padding = { left = 1, right = 1 } }),
                        make_component(lsp_status_short, { color = { fg = p.lavender, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {
                        make_component("filetype", { colored = false, color = { fg = p.cyan, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = bg }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 22. Bracketed
        local function setup_bracketed()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        bracket_comp({ "mode", fmt = format_mode_name_only }, get_mode_color),
                    },
                    lualine_b = {
                        bracket_comp("branch", p.green),
                    },
                    lualine_c = {
                        bracket_comp({ "filename", symbols = { modified = " ●" } }, p.normal_fg),
                    },
                    lualine_x = {
                        bracket_comp("diagnostics", p.yellow),
                        bracket_comp(lsp_status_short, p.lavender),
                    },
                    lualine_y = {
                        bracket_comp("filetype", p.cyan),
                    },
                    lualine_z = {
                        bracket_comp("location", get_mode_color),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { bracket_comp("filename", p.comment) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 23. Dot Matrix
        local function setup_dot_matrix()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "•", right = "•" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { color = { fg = p.green, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.normal_fg, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component(lsp_status_short, { color = { fg = p.lavender, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {},
                    lualine_z = {
                        make_component("location", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 24. Status Dashboard
        local function setup_dashboard()
            local p = get_theme_palette()
            local bg = flat_bg()
            local panel_bg = blend(p.normal_fg, bg, 0.06)

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "║", right = "║" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component({ "mode", fmt = format_mode }, {
                            color = function()
                                local mc = get_mode_color()
                                return { fg = contrast_fg(mc), bg = mc, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { icon = icons.branch, color = { fg = p.green, bg = panel_bg, gui = "bold" }, padding = { left = 1, right = 1 } }),
                        make_component("diff", { color = { bg = panel_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.normal_fg, bg = panel_bg },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { color = { bg = panel_bg }, padding = { left = 1, right = 1 } }),
                        make_component(lsp_status, { color = { fg = p.lavender, bg = panel_bg }, padding = { left = 1, right = 1 } }),
                        make_component(copilot_status, {
                            color = function()
                                return { fg = copilot_color(), bg = panel_bg }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_y = {
                        make_component(python_venv, { color = { fg = p.green, bg = panel_bg }, padding = { left = 1, right = 1 } }),
                        make_component("filetype", { color = { fg = p.cyan, bg = panel_bg }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = panel_bg, gui = "bold" }, padding = { left = 1, right = 1 } }),
                        make_component("progress", { color = { fg = p.comment, bg = panel_bg }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 25. Zen
        local function setup_zen()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●", readonly = " " } }, {
                            color = { fg = p.normal_fg, bg = "NONE" },
                            padding = { left = 2, right = 1 },
                        }),
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {
                        make_component("location", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 2 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 26. Split
        local function setup_split()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component({ "mode", fmt = format_mode }, { separator = separators.powerline }),
                    },
                    lualine_b = {
                        make_component("branch", { padding = { left = 1, right = 1 } }),
                        make_component("diff", { padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.comment },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", { padding = { left = 1, right = 1 } }),
                    },
                    lualine_y = {
                        make_component(lsp_status_short, { color = { fg = p.lavender }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { separator = { left = separators.powerline.left } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }) },
                    lualine_x = { make_component("location") },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 27. Tab Focused
        local function setup_tab_focused()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_icon_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {},
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = function()
                                return { fg = get_mode_color(), bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                        make_component("diagnostics", { color = { bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_x = {},
                    lualine_y = {
                        make_component("filetype", { colored = false, icon_only = true, color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 28. Dense
        local function setup_dense()
            local p = get_theme_palette()
            local bg = flat_bg()

            require("lualine").setup({
                options = {
                    theme = make_flat_theme(bg),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = "│", right = "│" },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = bg, gui = "bold" }
                            end,
                            padding = { left = 0, right = 0 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { icon = icons.branch, color = { fg = p.green, bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component("diff", { color = { bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component(git_conflict, { color = { fg = p.red, bg = bg }, padding = { left = 0, right = 0 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = "●", readonly = "" } }, {
                            color = { fg = p.normal_fg, bg = bg },
                            padding = { left = 0, right = 0 },
                        }),
                    },
                    lualine_x = {
                        make_component(macro_recording, { color = { fg = p.red, bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component("diagnostics", { color = { bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component(lsp_status_short, { color = { fg = p.lavender, bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component(copilot_status, {
                            color = function()
                                return { fg = copilot_color(), bg = bg }
                            end,
                            padding = { left = 0, right = 0 },
                        }),
                    },
                    lualine_y = {
                        make_component(python_venv, { color = { fg = p.green, bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component("filetype", { colored = false, icon_only = true, color = { fg = p.cyan, bg = bg }, padding = { left = 0, right = 0 } }),
                        make_component("encoding", { color = { fg = p.comment, bg = bg }, padding = { left = 0, right = 0 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.normal_fg, bg = bg, gui = "bold" }, padding = { left = 0, right = 0 } }),
                        make_component("progress", { color = { fg = p.comment, bg = bg }, padding = { left = 0, right = 0 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = bg } }) },
                    lualine_x = { make_component("location", { color = { fg = p.comment, bg = bg } }) },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 29. Spacious
        local function setup_spacious()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = separators.none,
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 3, right = 3 },
                        }),
                    },
                    lualine_b = {},
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.normal_fg, bg = "NONE" },
                            padding = { left = 3, right = 3 },
                        }),
                    },
                    lualine_x = {},
                    lualine_y = {
                        make_component("filetype", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 3, right = 3 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 3, right = 3 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE" }, padding = { left = 3, right = 3 } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        -- 30. Editorial
        local function setup_editorial()
            local p = get_theme_palette()

            require("lualine").setup({
                options = {
                    theme = make_transparent_theme(),
                    globalstatus = true,
                    section_separators = separators.none,
                    component_separators = { left = " ", right = " " },
                    always_divide_middle = true,
                    disabled_filetypes = disabled_fts,
                },
                sections = {
                    lualine_a = {
                        make_component(format_mode_name_only, {
                            color = function()
                                return { fg = get_mode_color(), bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_b = {
                        make_component("branch", { icon = "", color = { fg = p.comment, bg = "NONE", gui = "italic" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_c = {
                        make_component({ "filename", path = 1, symbols = { modified = " ●" } }, {
                            color = { fg = p.normal_fg, bg = "NONE", gui = "bold" },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_x = {
                        make_component("diagnostics", {
                            symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " },
                            color = { bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        }),
                    },
                    lualine_y = {
                        make_component("filetype", { colored = false, icon_only = false, color = { fg = p.comment, bg = "NONE", gui = "italic" }, padding = { left = 1, right = 1 } }),
                    },
                    lualine_z = {
                        make_component("location", { color = { fg = p.comment, bg = "NONE" }, padding = { left = 1, right = 1 } }),
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { make_component({ "filename", path = 1 }, { color = { fg = p.comment, bg = "NONE", gui = "italic" } }) },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end

        ----------------------------------------------------------------------
        -- Style map
        ----------------------------------------------------------------------

        local style_setups = {
            nvchad = setup_nvchad,
            lazyvim = setup_lazyvim,
            evil = setup_eviline,
            frosted = setup_frosted,
            pure_minimal = setup_pure_minimal,
            powerline = setup_powerline,
            soft_powerline = setup_soft_powerline,
            block = setup_block,
            rounded_pills = setup_rounded_pills,
            segmented = setup_segmented,
            airline = setup_airline,
            helix = setup_helix,
            doom = setup_doom,
            retro = setup_retro,
            cyberpunk = setup_cyberpunk,
            glassmorphism = setup_glassmorphism,
            floating = setup_floating,
            capsule = setup_capsule,
            edge = setup_edge,
            minimal_powerline = setup_minimal_powerline,
            vertical_divider = setup_vertical_divider,
            bracketed = setup_bracketed,
            dot_matrix = setup_dot_matrix,
            dashboard = setup_dashboard,
            zen = setup_zen,
            split = setup_split,
            tab_focused = setup_tab_focused,
            dense = setup_dense,
            spacious = setup_spacious,
            editorial = setup_editorial,
        }

        ----------------------------------------------------------------------
        -- Apply selected style
        ----------------------------------------------------------------------

        local function apply()
            local style = get_style()
            local setup_fn = style_setups[style]

            if setup_fn then
                setup_fn()
            else
                setup_frosted()
            end

            vim.api.nvim_set_hl(
                0,
                "StatusLine",
                { bg = "NONE" }
            )

            vim.api.nvim_set_hl(
                0,
                "StatusLineNC",
                { bg = "NONE" }
            )
        end

        ----------------------------------------------------------------------
        -- Refresh other UI components
        ----------------------------------------------------------------------

        local function refresh_barbar()
            vim.api.nvim_exec_autocmds(
                "User",
                {
                    pattern = "StatusStyleChanged",
                }
            )
        end

        local function refresh_incline()
            pcall(function()
                require("incline").refresh()
            end)
        end

        ----------------------------------------------------------------------
        -- Apply style
        ----------------------------------------------------------------------

        local function apply_style(style_id)
            vim.g.lualine_color_style = style_id
            status_style.save_style(style_id)

            apply()
            refresh_barbar()
            refresh_incline()

            local display = style_id
            for _, s in ipairs(styles) do
                if s.id == style_id then
                    display = s.name
                    break
                end
            end

            vim.notify(
                "UI Style: " .. display,
                vim.log.levels.INFO,
                {
                    title = "Status Style",
                }
            )
        end

        ----------------------------------------------------------------------
        -- StatusStyle command
        ----------------------------------------------------------------------

        local function set_statusline_style(style_id)
            if not style_id or style_id == "" then
                local ok, snacks = pcall(require, "snacks")
                local initial_style = get_style()

                local items = {}
                for _, s in ipairs(styles) do
                    table.insert(items, {
                        text = s.name,
                        id = s.id,
                        is_current = (s.id == initial_style),
                    })
                end

                if ok and snacks and snacks.picker then
                    snacks.picker.pick({
                        title = " Statusline & Tab Style ",
                        items = items,
                        layout = {
                            preset = "select",
                            preview = false,
                            width = 0.52,
                            min_width = 38,
                            height = 0.60,
                        },
                        format = function(item)
                            local icon = item.is_current and "● " or "○ "
                            local cur_str = item.is_current and " (active)" or ""
                            return {
                                { icon, item.is_current and "Function" or "Comment" },
                                { item.text .. " ", "Normal" },
                                { cur_str, "DiagnosticOk" },
                            }
                        end,
                        on_change = function(item)
                            if item and item.id then
                                vim.g.lualine_color_style = item.id
                                apply()
                                refresh_barbar()
                                refresh_incline()
                            end
                        end,
                        confirm = function(picker, item)
                            picker:close()
                            if item and item.id then
                                apply_style(item.id)
                            end
                        end,
                        cancel = function(picker)
                            picker:close()
                            vim.g.lualine_color_style = initial_style
                            apply()
                            refresh_barbar()
                            refresh_incline()
                        end,
                    })
                    return
                end

                local choices = {}
                for _, style in ipairs(styles) do
                    table.insert(choices, style.name)
                end

                vim.ui.select(
                    choices,
                    {
                        prompt = "Choose Statusline & Header Style:",
                    },
                    function(choice)
                        if not choice then
                            return
                        end

                        for _, style in ipairs(styles) do
                            if choice == style.name then
                                apply_style(style.id)
                                return
                            end
                        end
                    end
                )

                return
            end

            if style_id == "next" then
                local current = get_style()
                local next_index = 1

                for i, style in ipairs(styles) do
                    if style.id == current then
                        next_index =
                            (i % #styles) + 1
                        break
                    end
                end

                apply_style(
                    styles[next_index].id
                )

                return
            end

            if style_id == "prev" then
                local current = get_style()
                local prev_index = #styles

                for i, style in ipairs(styles) do
                    if style.id == current then
                        prev_index = i > 1 and (i - 1) or #styles
                        break
                    end
                end

                apply_style(
                    styles[prev_index].id
                )

                return
            end

            style_id =
                aliases[tostring(style_id)]
                or tostring(style_id)

            if style_lookup[style_id] then
                apply_style(style_id)
                return
            end

            vim.notify(
                "Unknown style: " .. tostring(style_id),
                vim.log.levels.WARN,
                {
                    title = "Status Style",
                }
            )
        end

        ----------------------------------------------------------------------
        -- Shared NvChad separator command
        ----------------------------------------------------------------------

        local function create_separator_command()
            if vim.fn.exists(":UISeparator") == 2 then
                return
            end

            vim.api.nvim_create_user_command(
                "UISeparator",
                function(opts)
                    local name =
                        tostring(opts.args):lower()

                    if not separators.nvchad[name] then
                        vim.notify(
                            "Use: default, round, block, arrow",
                            vim.log.levels.WARN,
                            {
                                title = "UI Separator",
                            }
                        )
                        return
                    end

                    vim.g.ui_nvchad_separator = name
                    status_style.save_separator(name)

                    apply()

                    vim.api.nvim_exec_autocmds(
                        "User",
                        {
                            pattern = "StatusStyleChanged",
                        }
                    )

                    refresh_incline()

                    vim.notify(
                        "NvChad separator: " .. name,
                        vim.log.levels.INFO,
                        {
                            title = "UI Separator",
                        }
                    )
                end,
                {
                    nargs = 1,

                    complete = function()
                        return {
                            "default",
                            "round",
                            "block",
                            "arrow",
                        }
                    end,

                    desc =
                        "Set shared NvChad separator style",
                }
            )
        end

        create_separator_command()

        ----------------------------------------------------------------------
        -- Main command
        ----------------------------------------------------------------------

        local complete_ids = {}
        for _, s in ipairs(styles) do
            table.insert(complete_ids, s.id)
        end
        table.insert(complete_ids, "next")
        table.insert(complete_ids, "prev")

        vim.api.nvim_create_user_command(
            "StatusStyle",
            function(opts)
                set_statusline_style(opts.args)
            end,
            {
                nargs = "?",

                complete = function()
                    return complete_ids
                end,

                desc =
                    "Switch Lualine + Barbar + Incline style",
            }
        )

        ----------------------------------------------------------------------
        -- Initial setup
        ----------------------------------------------------------------------

        apply()

        ----------------------------------------------------------------------
        -- Colorscheme refresh
        ----------------------------------------------------------------------

        vim.api.nvim_create_autocmd(
            "ColorScheme",
            {
                group = lualine_group,
                pattern = "*",

                callback = function()
                    cached_palette = nil

                    apply()

                    vim.schedule(function()
                        refresh_barbar()
                        refresh_incline()
                    end)
                end,
            }
        )
    end,
}
