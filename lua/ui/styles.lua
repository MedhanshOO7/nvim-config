-- Registry of the 30 UI styles shared by lualine and barbar (:StatusStyle).
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

return {
    list = styles,
    lookup = style_lookup,
    aliases = aliases,
    -- Active style id from vim.g.lualine_color_style (defaults to frosted)
    current = get_style,
}
