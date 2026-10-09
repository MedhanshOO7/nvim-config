-- Theme-aware colour lookup.
-- Plugins that need raw hex colours (rainbow brackets, dashboard gradient,
-- split glow) read them from the active colorscheme's highlight groups so
-- they follow ThemePicker / Matugen instead of being pinned to Catppuccin.
local M = {}

local function hl_hex(name, key)
    local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and value and value[key] then
        return string.format("#%06x", value[key])
    end
end

--- First foreground (or `key`) colour found among `groups`, else `fallback`.
function M.pick(groups, fallback, key)
    for _, group in ipairs(groups) do
        local value = hl_hex(group, key or "fg")
        if value then
            return value
        end
    end
    return fallback
end

local function to_rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

--- Mix `a` towards `b`; alpha = 1 returns `a`, alpha = 0 returns `b`.
function M.blend(a, b, alpha)
    local ar, ag, ab = to_rgb(a)
    local br, bg, bb = to_rgb(b)
    local function mix(x, y)
        return math.floor(x * alpha + y * (1 - alpha) + 0.5)
    end
    return string.format("#%02x%02x%02x", mix(ar, br), mix(ag, bg), mix(ab, bb))
end

--- Semantic colours resolved from the current colorscheme.
function M.colors()
    return {
        bg = M.pick({ "Normal" }, "#1e1e2e", "bg"),
        fg = M.pick({ "Normal" }, "#cdd6f4"),
        red = M.pick({ "DiagnosticError", "ErrorMsg" }, "#f38ba8"),
        yellow = M.pick({ "DiagnosticWarn", "WarningMsg" }, "#f9e2af"),
        blue = M.pick({ "Function", "Identifier" }, "#89b4fa"),
        orange = M.pick({ "Constant", "Number" }, "#fab387"),
        green = M.pick({ "String", "DiagnosticOk" }, "#a6e3a1"),
        violet = M.pick({ "Statement", "Keyword" }, "#cba6f7"),
        cyan = M.pick({ "Type", "Special", "DiagnosticHint" }, "#89dceb"),
    }
end

--- `n` evenly spaced colours walking through `stops` (at least two hex colours).
function M.gradient(stops, n)
    local out = {}
    local segments = #stops - 1
    for i = 0, n - 1 do
        local t = (n == 1) and 0 or i / (n - 1) * segments
        local idx = math.min(math.floor(t), segments - 1)
        local local_t = t - idx
        out[#out + 1] = M.blend(stops[idx + 2], stops[idx + 1], local_t)
    end
    return out
end

return M
