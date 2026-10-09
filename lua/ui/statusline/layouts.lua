-- The 30 statusline layouts. Each function calls lualine.setup() with a
-- complete config; ui.statusline picks one based on the active style.
local colors = require("ui.colors")
local sep = require("ui.separators")
local parts = require("ui.statusline.parts")

local blend = colors.blend
local separators = sep.separators
local get_nvchad_separator = sep.nvchad_current
local icons = parts.icons
local get_theme_palette = parts.get_theme_palette
local contrast_fg = parts.contrast_fg
local flat_bg = parts.flat_bg
local get_mode_color = parts.get_mode_color
local format_mode = parts.format_mode
local format_evil_mode = parts.format_evil_mode
local format_mode_name_only = parts.format_mode_name_only
local format_mode_icon_only = parts.format_mode_icon_only
local macro_recording = parts.macro_recording
local git_conflict = parts.git_conflict
local buffer_modified = parts.buffer_modified
local python_venv = parts.python_venv
local lsp_progress = parts.lsp_progress
local lsp_status = parts.lsp_status
local lsp_status_short = parts.lsp_status_short
local copilot_status = parts.copilot_status
local copilot_color = parts.copilot_color
local disabled_fts = parts.disabled_fts
local extensions = parts.extensions
local make_component = parts.make_component
local frosted_pill = parts.frosted_pill
local bracket_comp = parts.bracket_comp
local make_transparent_theme = parts.make_transparent_theme
local make_flat_theme = parts.make_flat_theme

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

return style_setups
