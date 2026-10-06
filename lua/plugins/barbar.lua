return {
    "romgrk/barbar.nvim",

    event = "VeryLazy",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    init = function()
        vim.g.barbar_auto_setup = false
        require("utils.status_style").load()

        ----------------------------------------------------------------------
        -- Shared NvChad separator.
        ----------------------------------------------------------------------

        vim.g.ui_nvchad_separator =
            vim.g.ui_nvchad_separator or "round"
    end,

    config = function()
        ----------------------------------------------------------------------
        -- Helpers
        ----------------------------------------------------------------------

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

        local function hex_to_rgb(hex)
            if not hex or hex == "NONE" then
                return 0, 0, 0
            end

            hex = tostring(hex):gsub("#", "")

            if #hex == 3 then
                hex = hex:gsub(".", "%1%1")
            end

            if not hex:match("^%x%x%x%x%x%x$") then
                return 0, 0, 0
            end

            return tonumber(hex:sub(1, 2), 16) or 0,
                tonumber(hex:sub(3, 4), 16) or 0,
                tonumber(hex:sub(5, 6), 16) or 0
        end

        local function blend(fg, bg, alpha)
            if fg == "NONE" then
                return bg
            end

            if bg == "NONE" then
                return "NONE"
            end

            local fr, fgreen, fb = hex_to_rgb(fg)
            local br, bgreen, bb = hex_to_rgb(bg)

            alpha = math.max(
                0,
                math.min(alpha or 0, 1)
            )

            return string.format(
                "#%02x%02x%02x",
                math.floor(
                    fr * alpha +
                    br * (1 - alpha) +
                    0.5
                ),

                math.floor(
                    fgreen * alpha +
                    bgreen * (1 - alpha) +
                    0.5
                ),

                math.floor(
                    fb * alpha +
                    bb * (1 - alpha) +
                    0.5
                )
            )
        end

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
        -- Shared separators
        --
        -- Same definitions as the Lualine file.
        ----------------------------------------------------------------------

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

        ----------------------------------------------------------------------
        -- Palette
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

        local function flat_bg()
            local bg = get_normal_bg()
            return bg == "NONE" and "#1e1e2e" or bg
        end

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
        -- Style selection (mirrors lualine.lua)
        ----------------------------------------------------------------------

        local style_ids = {
            "nvchad", "lazyvim", "evil", "frosted",
            "pure_minimal", "powerline", "soft_powerline", "block",
            "rounded_pills", "segmented", "airline", "helix",
            "doom", "retro", "cyberpunk", "glassmorphism",
            "floating", "capsule", "edge", "minimal_powerline",
            "vertical_divider", "bracketed", "dot_matrix", "dashboard",
            "zen", "split", "tab_focused", "dense",
            "spacious", "editorial",
        }

        local style_set = {}
        local aliases = {}
        for i, id in ipairs(style_ids) do
            style_set[id] = true
            aliases[tostring(i)] = id
        end

        local function get_style()
            local style = tostring(
                vim.g.lualine_color_style or "frosted"
            ):lower()

            return aliases[style]
                or style_set[style] and style
                or "frosted"
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

        ----------------------------------------------------------------------
        -- Barbar setup
        ----------------------------------------------------------------------

        local function setup_barbar()
            local p = get_palette()
            local s = get_style_colors(p)
            local style = get_style()

            local max_pad = 2
            local min_pad = 1

            if style == "dense" or style == "retro" or style == "doom"
                or style == "helix" or style == "pure_minimal" then
                max_pad = 1
                min_pad = 0
            elseif style == "spacious" or style == "capsule"
                or style == "glassmorphism" or style == "airline" then
                max_pad = 3
                min_pad = 1
            end

            require("barbar").setup({
                animation = true,
                auto_hide = false,

                tabpages = false,
                clickable = true,

                focus_on_close = "left",

                maximum_padding = max_pad,
                minimum_padding = min_pad,

                maximum_length = 25,
                minimum_length = 0,

                insert_at_end = true,
                semantic_letters = true,

                sort = {
                    ignore_case = true,
                },

                icons = {
                    preset = "powerline",

                    buffer_index = true,
                    buffer_number = false,

                    button = "",

                    modified = {
                        button = "●",
                    },

                    filetype = {
                        enabled = true,
                        custom_colors = false,
                        highlight_inactive = false,
                    },

                    ------------------------------------------------------------------
                    -- Base separator.
                    ------------------------------------------------------------------

                    separator = {
                        left = separators.none.left,
                        right = separators.none.right,
                    },

                    separator_at_end = false,

                    ------------------------------------------------------------------
                    -- Current buffer
                    ------------------------------------------------------------------

                    current = {
                        separator = {
                            left = s.current_separator.left,
                            right = s.current_separator.right,
                        },

                        buffer_index = true,
                        buffer_number = false,
                    },

                    ------------------------------------------------------------------
                    -- Inactive
                    ------------------------------------------------------------------

                    inactive = {
                        separator = {
                            left = s.inactive_separator.left,
                            right = s.inactive_separator.right,
                        },

                        button = "",
                    },

                    ------------------------------------------------------------------
                    -- Alternate
                    ------------------------------------------------------------------

                    alternate = {
                        separator = {
                            left = s.alternate_separator.left,
                            right = s.alternate_separator.right,
                        },
                    },

                    ------------------------------------------------------------------
                    -- Visible
                    ------------------------------------------------------------------

                    visible = {
                        separator = {
                            left = s.visible_separator.left,
                            right = s.visible_separator.right,
                        },
                    },

                    ------------------------------------------------------------------
                    -- Pinned
                    ------------------------------------------------------------------

                    pinned = {
                        button = "",
                        filename = true,
                    },

                    ------------------------------------------------------------------
                    -- Diagnostics
                    ------------------------------------------------------------------

                    diagnostics = {
                        [vim.diagnostic.severity.ERROR] = {
                            enabled = true,
                            icon = " ",
                        },

                        [vim.diagnostic.severity.WARN] = {
                            enabled = true,
                            icon = " ",
                        },

                        [vim.diagnostic.severity.INFO] = {
                            enabled = true,
                            icon = " ",
                        },

                        [vim.diagnostic.severity.HINT] = {
                            enabled = true,
                            icon = " ",
                        },
                    },

                    ------------------------------------------------------------------
                    -- Git
                    ------------------------------------------------------------------

                    gitsigns = {
                        added = {
                            enabled = true,
                            icon = " ",
                        },

                        changed = {
                            enabled = true,
                            icon = " ",
                        },

                        deleted = {
                            enabled = true,
                            icon = " ",
                        },
                    },
                },

                ------------------------------------------------------------------
                -- Sidebar filetypes
                ------------------------------------------------------------------

                sidebar_filetypes = {
                    ["snacks_picker_input"] = {
                        event = "BufWipeout",
                        text = "  Explorer",
                        align = "left",
                    },

                    ["snacks_explorer"] = {
                        event = "BufWipeout",
                        text = "  Explorer",
                        align = "left",
                    },

                    ["oil"] = {
                        event = "BufWipeout",
                        text = "  Oil Browser",
                        align = "left",
                    },

                    ["mini.files"] = {
                        event = "BufWipeout",
                        text = "  Mini Files",
                        align = "left",
                    },

                    ["neo-tree"] = {
                        event = "BufWipeout",
                        text = "  NeoTree",
                        align = "left",
                    },

                    ["NvimTree"] = {
                        event = "BufWipeout",
                        text = "  NvimTree",
                        align = "left",
                    },
                },

                highlight_alternate = true,
                highlight_inactive_file_icons = false,
                highlight_visible = true,

                ------------------------------------------------------------------
                -- Do not hide JSON/YAML/TOML.
                ------------------------------------------------------------------

                exclude_ft = {},

                no_name_title = "[No Name]",
            })

            apply(p, s)
        end

        ----------------------------------------------------------------------
        -- Initial setup
        ----------------------------------------------------------------------

        setup_barbar()

        vim.schedule(function()
            setup_barbar()
        end)

        ----------------------------------------------------------------------
        -- Shared style refresh
        ----------------------------------------------------------------------

        local barbar_group = vim.api.nvim_create_augroup(
            "barbar_dynamic_hl",
            { clear = true }
        )

        vim.api.nvim_create_autocmd(
            "User",
            {
                group = barbar_group,
                pattern = "StatusStyleChanged",

                callback = function()
                    setup_barbar()

                    vim.schedule(function()
                        setup_barbar()
                    end)
                end,
            }
        )

        ----------------------------------------------------------------------
        -- Colorscheme refresh
        ----------------------------------------------------------------------

        vim.api.nvim_create_autocmd(
            "ColorScheme",
            {
                group = barbar_group,
                pattern = "*",

                callback = function()
                    apply()

                    vim.schedule(function()
                        setup_barbar()
                    end)
                end,
            }
        )

        ----------------------------------------------------------------------
        -- Fallback command.
        ----------------------------------------------------------------------

        if vim.fn.exists(":UISeparator") ~= 2 then
            vim.api.nvim_create_user_command(
                "UISeparator",
                function(opts)
                    local name =
                        tostring(opts.args):lower()

                    if not separators.nvchad[name] then
                        vim.notify(
                            "Use: default, round, block, arrow",
                            vim.log.levels.WARN,
                            {
                                title = "UI Separator",
                            }
                        )
                        return
                    end

                    vim.g.ui_nvchad_separator = name
                    require("utils.status_style").save_separator(name)

                    setup_barbar()

                    vim.api.nvim_exec_autocmds(
                        "User",
                        {
                            pattern =
                                "StatusStyleChanged",
                        }
                    )

                    vim.notify(
                        "NvChad separator: " .. name,
                        vim.log.levels.INFO,
                        {
                            title = "UI Separator",
                        }
                    )
                end,
                {
                    nargs = 1,

                    complete = function()
                        return {
                            "default",
                            "round",
                            "block",
                            "arrow",
                        }
                    end,

                    desc =
                        "Set shared NvChad separator style",
                }
            )
        end

        ----------------------------------------------------------------------
        -- Keymaps
        --
        -- Safe Alt mappings for buffer navigation.
        ----------------------------------------------------------------------

        local map = vim.keymap.set

        local opts = {
            noremap = true,
            silent = true,
        }

        for i = 1, 9 do
            map(
                "n",
                "<A-" .. i .. ">",
                "<Cmd>BufferGoto " .. i .. "<CR>",
                opts
            )
        end

        map(
            "n",
            "<A-0>",
            "<Cmd>BufferLast<CR>",
            opts
        )

        map(
            "n",
            "<A-,>",
            "<Cmd>BufferPrevious<CR>",
            opts
        )

        map(
            "n",
            "<A-.>",
            "<Cmd>BufferNext<CR>",
            opts
        )

        map(
            "n",
            "<leader>bh",
            "<Cmd>BufferMovePrevious<CR>",
            opts
        )

        map(
            "n",
            "<leader>bl",
            "<Cmd>BufferMoveNext<CR>",
            opts
        )

        map(
            "n",
            "<leader>bd",
            "<Cmd>BufferClose<CR>",
            opts
        )

        map(
            "n",
            "<leader>bp",
            "<Cmd>BufferPick<CR>",
            opts
        )

        map(
            "n",
            "<leader>bP",
            "<Cmd>BufferPin<CR>",
            opts
        )
    end,
}
