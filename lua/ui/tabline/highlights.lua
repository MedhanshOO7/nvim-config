-- Palette and Buffer* highlight groups for the barbar tabline.
local colors = require("ui.colors")

local first_hl = colors.first_hl
local get_normal_bg = colors.get_normal_bg
local get_style_colors = require("ui.tabline.styles")

local function get_palette()
    return {
        base_bg = get_normal_bg(),

        text =
            first_hl(
                { "Normal", "NormalFloat" },
                "fg",
                "#c0caf5"
            ),

        muted =
            first_hl(
                { "Comment", "LineNr" },
                "fg",
                "#565f89"
            ),

        subtext =
            first_hl(
                { "NonText", "StatusLineNC" },
                "fg",
                "#7aa2f7"
            ),

        accent =
            first_hl(
                {
                    "Function",
                    "Special",
                    "Identifier",
                    "@keyword",
                    "Title",
                },
                "fg",
                "#7aa2f7"
            ),

        red =
            first_hl(
                {
                    "DiagnosticError",
                    "ErrorMsg",
                },
                "fg",
                "#f7768e"
            ),

        yellow =
            first_hl(
                {
                    "DiagnosticWarn",
                    "WarningMsg",
                },
                "fg",
                "#e0af68"
            ),

        cyan =
            first_hl(
                {
                    "DiagnosticInfo",
                    "Type",
                    "Special",
                },
                "fg",
                "#7dcfff"
            ),

        green =
            first_hl(
                {
                    "String",
                    "DiagnosticOk",
                    "GitSignsAdd",
                },
                "fg",
                "#9ece6a"
            ),

        purple =
            first_hl(
                {
                    "Statement",
                    "Keyword",
                },
                "fg",
                "#bb9af7"
            ),

        lavender =
            first_hl(
                {
                    "Identifier",
                    "PreProc",
                },
                "fg",
                "#b4befe"
            ),

        added =
            first_hl(
                {
                    "GitSignsAdd",
                    "DiffAdd",
                },
                "fg",
                "#9ece6a"
            ),

        changed =
            first_hl(
                {
                    "GitSignsChange",
                    "DiffChange",
                },
                "fg",
                "#e0af68"
            ),

        deleted =
            first_hl(
                {
                    "GitSignsDelete",
                    "DiffDelete",
                },
                "fg",
                "#f7768e"
            ),
    }
end

----------------------------------------------------------------------
-- Apply state highlights
----------------------------------------------------------------------

local function apply_state(
    prefix,
    fg,
    bg,
    bold,
    italic
)
    local set = vim.api.nvim_set_hl

    set(0, prefix, {
        fg = fg,
        bg = bg,
        bold = bold or false,
        italic = italic or false,
    })

    set(0, prefix .. "Index", {
        fg = fg,
        bg = bg,
        bold = bold or false,
        italic = italic or false,
    })

    set(0, prefix .. "Icon", {
        fg = fg,
        bg = bg,
    })

    set(0, prefix .. "Btn", {
        fg = fg,
        bg = bg,
    })

    set(0, prefix .. "Pin", {
        fg = fg,
        bg = bg,
    })

    set(0, prefix .. "PinBtn", {
        fg = fg,
        bg = bg,
    })

    ------------------------------------------------------------------
    -- Separator highlights.
    --
    -- NONE is intentional here so transparent themes don't gain
    -- an accidental opaque strip behind the caps.
    ------------------------------------------------------------------

    set(0, prefix .. "Sign", {
        fg = bg,
        bg = "NONE",
    })

    set(0, prefix .. "SignRight", {
        fg = bg,
        bg = "NONE",
    })
end

----------------------------------------------------------------------
-- Apply all highlights
----------------------------------------------------------------------

local function apply(p, s)
    p = p or get_palette()
    s = s or get_style_colors(p)
    local set = vim.api.nvim_set_hl

    ------------------------------------------------------------------
    -- Main buffers
    ------------------------------------------------------------------

    apply_state(
        "BufferCurrent",
        s.current_fg,
        s.current_bg,
        s.bold_current,
        false
    )

    apply_state(
        "BufferInactive",
        s.inactive_fg,
        s.inactive_bg,
        false,
        s.italic_inactive
    )

    apply_state(
        "BufferAlternate",
        s.alternate_fg,
        s.alternate_bg,
        false,
        s.italic_inactive
    )

    apply_state(
        "BufferVisible",
        s.visible_fg,
        s.visible_bg,
        false,
        false
    )

    ------------------------------------------------------------------
    -- Diagnostic / git states
    ------------------------------------------------------------------

    local current_states = {
        Mod = p.yellow,
        Target = p.red,
        ERROR = p.red,
        WARN = p.yellow,
        INFO = p.cyan,
        HINT = p.accent,
        ADDED = p.added,
        CHANGED = p.changed,
        DELETED = p.deleted,
    }

    for suffix, fg in pairs(current_states) do
        set(
            0,
            "BufferCurrent" .. suffix,
            {
                fg = fg,
                bg = s.current_bg,
                bold = true,
            }
        )

        set(
            0,
            "BufferInactive" .. suffix,
            {
                fg = fg,
                bg = s.inactive_bg,
            }
        )

        set(
            0,
            "BufferAlternate" .. suffix,
            {
                fg = fg,
                bg = s.alternate_bg,
            }
        )

        set(
            0,
            "BufferVisible" .. suffix,
            {
                fg = fg,
                bg = s.visible_bg,
            }
        )
    end

    ------------------------------------------------------------------
    -- Tabline background
    ------------------------------------------------------------------

    local fill = s.fill_bg

    set(0, "BufferTabpageFill", {
        fg = p.muted,
        bg = fill,
    })

    set(0, "BufferTabpages", {
        fg = p.accent,
        bg = fill,
        bold = true,
    })

    set(0, "BufferTabpagesSep", {
        fg = p.muted,
        bg = fill,
    })

    set(0, "BufferOffset", {
        bg = fill,
    })

    set(0, "BufferScrollArrow", {
        fg = p.accent,
        bg = fill,
        bold = true,
    })

    set(0, "TabLine", {
        fg = p.text,
        bg = fill,
    })

    set(0, "TabLineFill", {
        bg = fill,
    })

    set(0, "TabLineSel", {
        fg = s.current_fg,
        bg = s.current_bg,
        bold = true,
    })
end

return {
    get_palette = get_palette,
    get_style_colors = get_style_colors,
    apply = apply,
}
