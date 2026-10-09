-- Barbar tabline: follows the shared :StatusStyle and the active colorscheme.
local separators = require("ui.separators").separators
local get_style = require("ui.styles").current
local hl = require("ui.tabline.highlights")

local get_palette = hl.get_palette
local get_style_colors = hl.get_style_colors
local apply = hl.apply

local M = {}

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

local function map_keys()
    local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
    end

    for i = 1, 9 do
        map("<A-" .. i .. ">", "<Cmd>BufferGoto " .. i .. "<CR>", "Go to buffer " .. i)
    end
    map("<A-0>", "<Cmd>BufferLast<CR>", "Go to last buffer")
    map("<A-,>", "<Cmd>BufferPrevious<CR>", "Previous buffer")
    map("<A-.>", "<Cmd>BufferNext<CR>", "Next buffer")

    map("<leader>bn", "<Cmd>BufferNext<CR>", "Next buffer")
    map("<leader>bp", "<Cmd>BufferPrevious<CR>", "Previous buffer")
    map("<leader>bb", "<Cmd>BufferPick<CR>", "Pick a buffer by letter")
    map("<leader>bd", "<Cmd>BufferClose<CR>", "Close the current buffer")
    map("<leader>bh", "<Cmd>BufferMovePrevious<CR>", "Move buffer left")
    map("<leader>bl", "<Cmd>BufferMoveNext<CR>", "Move buffer right")
    map("<leader>bP", "<Cmd>BufferPin<CR>", "Pin or unpin buffer")
end

function M.setup()
    setup_barbar()
    vim.schedule(setup_barbar)

    local group = vim.api.nvim_create_augroup("barbar_dynamic_hl", { clear = true })

    -- Fired by ui.statusline whenever :StatusStyle / :UISeparator changes
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "StatusStyleChanged",
        callback = function()
            setup_barbar()
            vim.schedule(setup_barbar)
        end,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
            apply()
            vim.schedule(setup_barbar)
        end,
    })

    map_keys()
end

return M
