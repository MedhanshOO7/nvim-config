-- Per-style colours and separators for the barbar tabline.
local colors = require("ui.colors")
local sep = require("ui.separators")

local blend = colors.blend
local hex_to_rgb = colors.hex_to_rgb
local flat_bg = colors.flat_bg
local separators = sep.separators
local get_nvchad_separator = sep.nvchad_current
local get_style = require("ui.styles").current

-- Black/white text for solid tab backgrounds (differs from the statusline's
-- palette-based contrast on purpose).
local function contrast_fg(bg, fallback)
    if bg == "NONE" then
        return fallback
    end

    local r, g, b = hex_to_rgb(bg)

    local luminance =
        (
            0.2126 * r +
            0.7152 * g +
            0.0722 * b
        ) / 255

    if luminance > 0.50 then
        return "#000000"
    end

    return "#ffffff"
end

----------------------------------------------------------------------
-- Style visual properties for Barbar
----------------------------------------------------------------------

local function get_style_colors(p)
    local style = get_style()
    local fbg = flat_bg()

    local result = {
        current_bg = p.base_bg,
        current_fg = p.text,
        inactive_bg = p.base_bg,
        inactive_fg = p.muted,
        alternate_bg = p.base_bg,
        alternate_fg = p.muted,
        visible_bg = p.base_bg,
        visible_fg = p.text,
        current_separator = separators.none,
        inactive_separator = separators.none,
        alternate_separator = separators.none,
        visible_separator = separators.none,
        fill_bg = p.base_bg,
        bold_current = false,
        italic_inactive = false,
    }

    ------------------------------------------------------------------
    -- 1. NvChad
    ------------------------------------------------------------------
    if style == "nvchad" then
        local separator = get_nvchad_separator()
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.current_separator = separator
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 2. LazyVim
    ------------------------------------------------------------------
    elseif style == "lazyvim" then
        result.current_bg = p.base_bg
        result.current_fg = p.text
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.fill_bg = p.base_bg

    ------------------------------------------------------------------
    -- 3. Eviline
    ------------------------------------------------------------------
    elseif style == "evil" then
        result.current_bg = fbg
        result.current_fg = p.text
        result.inactive_bg = fbg
        result.inactive_fg = p.muted
        result.alternate_bg = fbg
        result.alternate_fg = p.muted
        result.visible_bg = fbg
        result.visible_fg = p.text
        result.fill_bg = fbg

    ------------------------------------------------------------------
    -- 4. Frosted Glass
    ------------------------------------------------------------------
    elseif style == "frosted" then
        if p.base_bg == "NONE" then
            result.current_bg = "NONE"
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        else
            result.current_bg = blend(p.accent, p.base_bg, 0.35)
            result.inactive_bg = blend(p.text, p.base_bg, 0.08)
            result.visible_bg = blend(p.accent, p.base_bg, 0.16)
            result.alternate_bg = blend(p.text, p.base_bg, 0.08)
        end
        result.current_fg = contrast_fg(result.current_bg, p.accent)
        result.inactive_fg = p.muted
        result.alternate_fg = p.muted
        result.visible_fg = p.subtext
        result.current_separator = separators.round
        result.inactive_separator = separators.round
        result.alternate_separator = separators.round
        result.visible_separator = separators.round
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 5. Pure Minimal
    ------------------------------------------------------------------
    elseif style == "pure_minimal" then
        result.current_bg = "NONE"
        result.current_fg = p.accent
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 6. Classic Powerline
    ------------------------------------------------------------------
    elseif style == "powerline" then
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.current_separator = separators.powerline
        result.inactive_separator = separators.powerline_soft
        result.alternate_separator = separators.powerline_soft
        result.visible_separator = separators.powerline_soft
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 7. Soft Powerline
    ------------------------------------------------------------------
    elseif style == "soft_powerline" then
        local soft_bg = p.base_bg ~= "NONE"
            and blend(p.accent, p.base_bg, 0.12)
            or "NONE"
        result.current_bg = soft_bg
        result.current_fg = p.text
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.current_separator = separators.powerline_soft
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 8. Block
    ------------------------------------------------------------------
    elseif style == "block" then
        local subtle_bg = p.base_bg ~= "NONE"
            and blend(p.text, p.base_bg, 0.08)
            or "NONE"
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = subtle_bg
        result.inactive_fg = p.muted
        result.alternate_bg = subtle_bg
        result.alternate_fg = p.muted
        result.visible_bg = subtle_bg
        result.visible_fg = p.text
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 9. Rounded Pills
    ------------------------------------------------------------------
    elseif style == "rounded_pills" then
        if p.base_bg == "NONE" then
            result.current_bg = "NONE"
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        else
            result.current_bg = blend(p.accent, p.base_bg, 0.30)
            result.inactive_bg = blend(p.text, p.base_bg, 0.06)
            result.visible_bg = blend(p.accent, p.base_bg, 0.12)
            result.alternate_bg = blend(p.text, p.base_bg, 0.06)
        end
        result.current_fg = contrast_fg(result.current_bg, p.accent)
        result.inactive_fg = p.muted
        result.alternate_fg = p.muted
        result.visible_fg = p.subtext
        result.current_separator = separators.round
        result.inactive_separator = separators.round
        result.alternate_separator = separators.round
        result.visible_separator = separators.round
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 10. Segmented
    ------------------------------------------------------------------
    elseif style == "segmented" then
        local seg_bg = p.base_bg ~= "NONE"
            and blend(p.text, p.base_bg, 0.06)
            or "NONE"
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = seg_bg
        result.inactive_fg = p.muted
        result.alternate_bg = seg_bg
        result.alternate_fg = p.muted
        result.visible_bg = seg_bg
        result.visible_fg = p.text
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 11. Airline
    ------------------------------------------------------------------
    elseif style == "airline" then
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.current_separator = separators.powerline
        result.inactive_separator = separators.powerline_soft
        result.alternate_separator = separators.powerline_soft
        result.visible_separator = separators.powerline_soft
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 12. Helix
    ------------------------------------------------------------------
    elseif style == "helix" then
        result.current_bg = fbg
        result.current_fg = p.accent
        result.inactive_bg = fbg
        result.inactive_fg = p.muted
        result.alternate_bg = fbg
        result.alternate_fg = p.muted
        result.visible_bg = fbg
        result.visible_fg = p.subtext
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 13. Doom
    ------------------------------------------------------------------
    elseif style == "doom" then
        result.current_bg = fbg
        result.current_fg = p.text
        result.inactive_bg = fbg
        result.inactive_fg = p.muted
        result.alternate_bg = fbg
        result.alternate_fg = p.muted
        result.visible_bg = fbg
        result.visible_fg = p.subtext
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 14. Retro Terminal
    ------------------------------------------------------------------
    elseif style == "retro" then
        result.current_bg = fbg
        result.current_fg = p.accent
        result.inactive_bg = fbg
        result.inactive_fg = p.muted
        result.alternate_bg = fbg
        result.alternate_fg = p.muted
        result.visible_bg = fbg
        result.visible_fg = p.subtext
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 15. Cyberpunk
    ------------------------------------------------------------------
    elseif style == "cyberpunk" then
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.current_separator = separators.slant_right
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 16. Glassmorphism
    ------------------------------------------------------------------
    elseif style == "glassmorphism" then
        if p.base_bg == "NONE" then
            result.current_bg = "NONE"
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        else
            result.current_bg = blend(p.accent, p.base_bg, 0.45)
            result.inactive_bg = blend(p.text, p.base_bg, 0.10)
            result.visible_bg = blend(p.accent, p.base_bg, 0.20)
            result.alternate_bg = blend(p.text, p.base_bg, 0.10)
        end
        result.current_fg = contrast_fg(result.current_bg, p.accent)
        result.inactive_fg = p.muted
        result.alternate_fg = p.muted
        result.visible_fg = p.subtext
        result.current_separator = separators.round
        result.inactive_separator = separators.round
        result.alternate_separator = separators.round
        result.visible_separator = separators.round
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 17. Floating
    ------------------------------------------------------------------
    elseif style == "floating" then
        if p.base_bg == "NONE" then
            result.current_bg = "NONE"
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        else
            result.current_bg = blend(p.accent, p.base_bg, 0.28)
            result.inactive_bg = blend(p.text, p.base_bg, 0.06)
            result.visible_bg = blend(p.accent, p.base_bg, 0.14)
            result.alternate_bg = blend(p.text, p.base_bg, 0.06)
        end
        result.current_fg = contrast_fg(result.current_bg, p.accent)
        result.inactive_fg = p.muted
        result.alternate_fg = p.muted
        result.visible_fg = p.subtext
        result.current_separator = separators.round
        result.inactive_separator = separators.round
        result.alternate_separator = separators.round
        result.visible_separator = separators.round
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 18. Capsule
    ------------------------------------------------------------------
    elseif style == "capsule" then
        if p.base_bg == "NONE" then
            result.current_bg = "NONE"
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        else
            result.current_bg = blend(p.accent, p.base_bg, 0.32)
            result.inactive_bg = blend(p.text, p.base_bg, 0.08)
            result.visible_bg = blend(p.accent, p.base_bg, 0.16)
            result.alternate_bg = blend(p.text, p.base_bg, 0.08)
        end
        result.current_fg = contrast_fg(result.current_bg, p.accent)
        result.inactive_fg = p.muted
        result.alternate_fg = p.muted
        result.visible_fg = p.subtext
        result.current_separator = separators.round
        result.inactive_separator = separators.round
        result.alternate_separator = separators.round
        result.visible_separator = separators.round
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 19. Edge
    ------------------------------------------------------------------
    elseif style == "edge" then
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.current_separator = separators.powerline
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 20. Minimal Powerline
    ------------------------------------------------------------------
    elseif style == "minimal_powerline" then
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.current_separator = separators.powerline
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 21. Vertical Divider
    ------------------------------------------------------------------
    elseif style == "vertical_divider" then
        result.current_bg = fbg
        result.current_fg = p.accent
        result.inactive_bg = fbg
        result.inactive_fg = p.muted
        result.alternate_bg = fbg
        result.alternate_fg = p.muted
        result.visible_bg = fbg
        result.visible_fg = p.subtext
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 22. Bracketed
    ------------------------------------------------------------------
    elseif style == "bracketed" then
        result.current_bg = "NONE"
        result.current_fg = p.accent
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 23. Dot Matrix
    ------------------------------------------------------------------
    elseif style == "dot_matrix" then
        result.current_bg = "NONE"
        result.current_fg = p.accent
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 24. Status Dashboard
    ------------------------------------------------------------------
    elseif style == "dashboard" then
        local panel_bg = p.base_bg ~= "NONE"
            and blend(p.text, p.base_bg, 0.06)
            or "NONE"
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = panel_bg
        result.inactive_fg = p.muted
        result.alternate_bg = panel_bg
        result.alternate_fg = p.muted
        result.visible_bg = panel_bg
        result.visible_fg = p.text
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 25. Zen
    ------------------------------------------------------------------
    elseif style == "zen" then
        result.current_bg = "NONE"
        result.current_fg = p.text
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 26. Split
    ------------------------------------------------------------------
    elseif style == "split" then
        result.current_bg = p.accent
        result.current_fg = contrast_fg(p.accent, p.text)
        result.inactive_bg = p.base_bg
        result.inactive_fg = p.muted
        result.alternate_bg = p.base_bg
        result.alternate_fg = p.muted
        result.visible_bg = p.base_bg
        result.visible_fg = p.text
        result.current_separator = separators.powerline
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 27. Tab Focused
    ------------------------------------------------------------------
    elseif style == "tab_focused" then
        if p.base_bg == "NONE" then
            result.current_bg = "NONE"
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        else
            result.current_bg = blend(p.accent, p.base_bg, 0.35)
            result.inactive_bg = "NONE"
            result.visible_bg = "NONE"
            result.alternate_bg = "NONE"
        end
        result.current_fg = contrast_fg(result.current_bg, p.accent)
        result.inactive_fg = p.muted
        result.alternate_fg = p.muted
        result.visible_fg = p.muted
        result.current_separator = separators.round
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 28. Dense
    ------------------------------------------------------------------
    elseif style == "dense" then
        result.current_bg = fbg
        result.current_fg = p.accent
        result.inactive_bg = fbg
        result.inactive_fg = p.muted
        result.alternate_bg = fbg
        result.alternate_fg = p.muted
        result.visible_bg = fbg
        result.visible_fg = p.subtext
        result.fill_bg = fbg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 29. Spacious
    ------------------------------------------------------------------
    elseif style == "spacious" then
        result.current_bg = "NONE"
        result.current_fg = p.accent
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.fill_bg = p.base_bg
        result.bold_current = true

    ------------------------------------------------------------------
    -- 30. Editorial
    ------------------------------------------------------------------
    elseif style == "editorial" then
        result.current_bg = "NONE"
        result.current_fg = p.text
        result.inactive_bg = "NONE"
        result.inactive_fg = p.muted
        result.alternate_bg = "NONE"
        result.alternate_fg = p.muted
        result.visible_bg = "NONE"
        result.visible_fg = p.subtext
        result.fill_bg = p.base_bg
        result.bold_current = true
        result.italic_inactive = true
    end

    return result
end

return get_style_colors
