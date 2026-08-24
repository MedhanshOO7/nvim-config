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
                    only_win = false,
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

                    -- Vibrant colored pill palette
                    local accent_color = hl_hex("Function", "fg") or hl_hex("Directory", "fg") or "#89b4fa"
                    local dark_text = "#11111b"
                    local unfocused_bg = hl_hex("CursorLine", "bg") or hl_hex("Pmenu", "bg") or "#313244"
                    local unfocused_fg = hl_hex("Comment", "fg") or "#a6adc8"

                    local pill_bg = props.focused and accent_color or unfocused_bg
                    local text_fg = props.focused and dark_text or unfocused_fg
                    local icon_fg = props.focused and dark_text or (icon_hl or unfocused_fg)

                    local parts = {}

                    -- Smooth left rounded pill cap
                    table.insert(parts, { "", guifg = pill_bg, guibg = "NONE" })

                    -- File icon
                    if icon then
                        table.insert(parts, {
                            icon .. " ",
                            guifg = icon_fg,
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
                            table.insert(parts, { " +" .. git.added, guifg = props.focused and "#1e4732" or "#a6e3a1", guibg = pill_bg, gui = "bold" })
                        end
                        if git.changed and git.changed > 0 then
                            table.insert(parts, { " ~" .. git.changed, guifg = props.focused and "#4a3c10" or "#f9e2af", guibg = pill_bg, gui = "bold" })
                        end
                        if git.removed and git.removed > 0 then
                            table.insert(parts, { " -" .. git.removed, guifg = props.focused and "#5e1919" or "#f38ba8", guibg = pill_bg, gui = "bold" })
                        end
                    end

                    -- Diagnostics
                    if diagnostics[vim.diagnostic.severity.ERROR] and diagnostics[vim.diagnostic.severity.ERROR] > 0 then
                        table.insert(parts, { "  " .. diagnostics[vim.diagnostic.severity.ERROR], guifg = props.focused and "#5e1919" or "#f38ba8", guibg = pill_bg, gui = "bold" })
                    elseif diagnostics[vim.diagnostic.severity.WARN] and diagnostics[vim.diagnostic.severity.WARN] > 0 then
                        table.insert(parts, { "  " .. diagnostics[vim.diagnostic.severity.WARN], guifg = props.focused and "#4a3c10" or "#fab387", guibg = pill_bg, gui = "bold" })
                    end

                    -- Modified indicator
                    if modified then
                        table.insert(parts, { " ●", guifg = props.focused and "#4a3c10" or "#f9e2af", guibg = pill_bg, gui = "bold" })
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
