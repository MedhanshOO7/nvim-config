-- Colour helpers shared by the statusline (lualine) and tabline (barbar).
local M = {}

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

M.glyph = glyph
M.hl_hex = hl_hex
M.first_hl = first_hl
M.to_hex = to_hex
M.hex_to_rgb = hex_to_rgb
M.blend = blend
M.get_normal_bg = get_normal_bg

-- Opaque fallback for styles that need a solid bar behind transparent themes.
function M.flat_bg()
    local bg = get_normal_bg()
    return bg == "NONE" and "#1e1e2e" or bg
end

return M
