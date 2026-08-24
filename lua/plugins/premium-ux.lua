return {
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("illuminate").configure({
                delay = 150,
                large_file_cutoff = 3000,
                large_file_overrides = {
                    providers = { "lsp", "treesitter" },
                },
                filetypes_denylist = {
                    "alpha",
                    "dashboard",
                    "help",
                    "lazy",
                    "mason",
                    "notify",
                    "snacks_dashboard",
                    "TelescopePrompt",
                    "toggleterm",
                },
                modes_denylist = { "i", "ic", "ix" },
            })
        end,
    },
    {
        "b0o/incline.nvim",
        event = "VeryLazy",
        config = function()
            local devicons = require("nvim-web-devicons")

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

            local function hl_hex(name, key, fallback)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                if ok and hl and hl[key] then
                    return string.format("#%06x", hl[key])
                end
                return fallback
            end

            local function apply_incline_transparent_hl()
                vim.api.nvim_set_hl(0, "InclineNormal", { bg = "NONE" })
                vim.api.nvim_set_hl(0, "InclineNormalNC", { bg = "NONE" })
            end

            apply_incline_transparent_hl()

            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("incline_transparent_sync", { clear = true }),
                pattern = "*",
                callback = apply_incline_transparent_hl,
            })

            require("incline").setup({
                debounce_threshold = {
                    falling = 40,
                    rising = 10,
                },
                hide = {
                    cursorline = false,
                    focused_win = false,
                    only_win = true,
                },
                highlight = {
                    groups = {
                        InclineNormal = { default = false, group = "InclineNormal" },
                        InclineNormalNC = { default = false, group = "InclineNormalNC" },
                    },
                },
                render = function(props)
                    local buf = props.buf
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
                    if filename == "" then
                        filename = "[No Name]"
                    end

                    local modified = vim.bo[buf].modified
                    local icon, icon_hl = devicons.get_icon_color(filename)
                    local diagnostics = vim.diagnostic.count(buf)

                    -- Theme-blended harmonious palette
                    local normal_bg = hl_hex("Normal", "bg", "#1e1e2e")
                    local normal_fg = hl_hex("Normal", "fg", "#cdd6f4")
                    local accent = hl_hex("Function", "fg", hl_hex("Identifier", "fg", "#89b4fa"))
                    local comment = hl_hex("Comment", "fg", "#6c7086")
                    local green = hl_hex("String", "fg", "#a6e3a1")
                    local yellow = hl_hex("DiagnosticWarn", "fg", "#f9e2af")
                    local red = hl_hex("DiagnosticError", "fg", "#f38ba8")

                    local pill_bg = props.focused and blend(accent, normal_bg, 0.60) or blend(normal_fg, normal_bg, 0.15)
                    local text_fg = props.focused and (hl_hex("Normal", "fg") or "#ffffff") or comment

                    local parts = {}

                    -- Smooth left rounded pill cap
                    table.insert(parts, { "", guifg = pill_bg, guibg = "NONE" })

                    -- File icon
                    if icon then
                        table.insert(parts, {
                            icon .. " ",
                            guifg = props.focused and (icon_hl or accent) or comment,
                            guibg = pill_bg,
                        })
                    end

                    -- Filename
                    table.insert(parts, {
                        filename,
                        guifg = text_fg,
                        guibg = pill_bg,
                        gui = props.focused and "bold" or "NONE",
                    })

                    -- Git diff status
                    local git = vim.b[buf].gitsigns_status_dict
                    if git then
                        if git.added and git.added > 0 then
                            table.insert(parts, { " +" .. git.added, guifg = green, guibg = pill_bg })
                        end
                        if git.changed and git.changed > 0 then
                            table.insert(parts, { " ~" .. git.changed, guifg = yellow, guibg = pill_bg })
                        end
                        if git.removed and git.removed > 0 then
                            table.insert(parts, { " -" .. git.removed, guifg = red, guibg = pill_bg })
                        end
                    end

                    -- Diagnostics
                    if diagnostics[vim.diagnostic.severity.ERROR] and diagnostics[vim.diagnostic.severity.ERROR] > 0 then
                        table.insert(parts, { "  " .. diagnostics[vim.diagnostic.severity.ERROR], guifg = red, guibg = pill_bg, gui = "bold" })
                    elseif diagnostics[vim.diagnostic.severity.WARN] and diagnostics[vim.diagnostic.severity.WARN] > 0 then
                        table.insert(parts, { "  " .. diagnostics[vim.diagnostic.severity.WARN], guifg = yellow, guibg = pill_bg, gui = "bold" })
                    end

                    -- Modified indicator
                    if modified then
                        table.insert(parts, { " ●", guifg = yellow, guibg = pill_bg, gui = "bold" })
                    end

                    -- Smooth right rounded pill cap
                    table.insert(parts, { "", guifg = pill_bg, guibg = "NONE" })

                    return parts
                end,
                window = {
                    margin = { horizontal = 1, vertical = 0 },
                    padding = 0,
                    placement = { horizontal = "right", vertical = "top" },
                    winhighlight = {
                        active = {
                            Normal = "InclineNormal",
                        },
                        inactive = {
                            Normal = "InclineNormalNC",
                        },
                    },
                },
            })
        end,
    },
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        opts = {
            auto_enable = true,
            auto_resize_height = true,
            preview = {
                border = "rounded",
                show_title = true,
                should_preview_cb = function(bufnr)
                    local filename = vim.api.nvim_buf_get_name(bufnr)
                    return filename ~= "" and vim.fn.getfsize(filename) < 1024 * 1024
                end,
            },
        },
    },
}
