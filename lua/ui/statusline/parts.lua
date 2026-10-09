-- Building blocks for the statusline layouts: palette, mode, components,
-- pill wrappers and lualine theme tables.
local colors = require("ui.colors")
local sep = require("ui.separators")

local glyph = colors.glyph
local first_hl = colors.first_hl
local hex_to_rgb = colors.hex_to_rgb
local blend = colors.blend
local get_normal_bg = colors.get_normal_bg
local separators = sep.separators

local M = {}

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

    -- vim.lsp.status() joins every queued message; keep the bar readable
    if vim.fn.strchars(status) > 48 then
        status = vim.fn.strcharpart(status, 0, 47) .. "…"
    end

    -- "100%: Loading…" — a bare % is a statusline escape and hangs lualine
    return (status:gsub("%%", "%%%%"))
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

-- Palette is cached until the colorscheme changes.
function M.reset_palette()
    cached_palette = nil
end

M.icons = icons
M.get_theme_palette = get_theme_palette
M.contrast_fg = contrast_fg
M.flat_bg = flat_bg
M.get_mode_color = get_mode_color
M.format_mode = format_mode
M.format_evil_mode = format_evil_mode
M.format_mode_name_only = format_mode_name_only
M.format_mode_icon_only = format_mode_icon_only
M.macro_recording = macro_recording
M.git_conflict = git_conflict
M.buffer_modified = buffer_modified
M.python_venv = python_venv
M.lsp_progress = lsp_progress
M.lsp_status = lsp_status
M.lsp_status_short = lsp_status_short
M.copilot_status = copilot_status
M.copilot_color = copilot_color
M.disabled_fts = disabled_fts
M.extensions = extensions
M.make_component = make_component
M.frosted_pill = frosted_pill
M.bracket_comp = bracket_comp
M.make_transparent_theme = make_transparent_theme
M.make_flat_theme = make_flat_theme

return M
