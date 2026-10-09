-- Powerline / NvChad separator glyphs shared by statusline and tabline.
local glyph = require("ui.colors").glyph

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

return {
    separators = separators,
    -- Current shared NvChad separator (:UISeparator default|round|block|arrow)
    nvchad_current = get_nvchad_separator,
}
