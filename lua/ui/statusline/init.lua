-- Statusline entry point: applies the active layout and owns the
-- :StatusStyle / :UISeparator commands shared with the barbar tabline.
local status_style = require("utils.status_style")
local styles = require("ui.styles")
local separators = require("ui.separators").separators
local parts = require("ui.statusline.parts")
local layouts = require("ui.statusline.layouts")

local M = {}

local function apply()
    local setup_fn = layouts[styles.current()] or layouts.frosted
    setup_fn()

    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
end

-- barbar listens for this event and re-styles the tabline
local function refresh_tabline()
    vim.api.nvim_exec_autocmds("User", { pattern = "StatusStyleChanged" })
end

local function apply_style(style_id)
    vim.g.lualine_color_style = style_id
    status_style.save_style(style_id)

    apply()
    refresh_tabline()

    local style = styles.lookup[style_id]
    vim.notify("UI Style: " .. (style and style.name or style_id), vim.log.levels.INFO, { title = "Status Style" })
end

-- Live-preview picker: moving the cursor previews, <CR> saves, <Esc> reverts.
local function pick_style()
    local initial_style = styles.current()
    local ok, snacks = pcall(require, "snacks")

    if ok and snacks and snacks.picker then
        local confirmed = false
        local items = {}
        for _, s in ipairs(styles.list) do
            table.insert(items, { text = s.name, id = s.id, is_current = (s.id == initial_style) })
        end

        snacks.picker.pick({
            title = " Statusline & Tab Style ",
            items = items,
            layout = { preset = "select", preview = false, width = 0.52, min_width = 38, height = 0.60 },
            format = function(item)
                return {
                    { item.is_current and "● " or "○ ", item.is_current and "Function" or "Comment" },
                    { item.text .. " ", "Normal" },
                    { item.is_current and " (active)" or "", "DiagnosticOk" },
                }
            end,
            on_change = function(_, item)
                if item and item.id then
                    vim.g.lualine_color_style = item.id
                    apply()
                    refresh_tabline()
                end
            end,
            confirm = function(picker, item)
                confirmed = true
                picker:close()
                if item and item.id then
                    apply_style(item.id)
                end
            end,
            -- Any close without confirm (<Esc>, q, <C-c>) reverts the preview
            on_close = function()
                if confirmed then
                    return
                end
                vim.g.lualine_color_style = initial_style
                apply()
                refresh_tabline()
            end,
        })
        return
    end

    local choices = {}
    for _, s in ipairs(styles.list) do
        table.insert(choices, s.name)
    end
    vim.ui.select(choices, { prompt = "Choose Statusline & Header Style:" }, function(choice)
        for _, s in ipairs(styles.list) do
            if choice == s.name then
                apply_style(s.id)
                return
            end
        end
    end)
end

local function step_style(delta)
    local current = styles.current()
    local count = #styles.list
    for i, s in ipairs(styles.list) do
        if s.id == current then
            apply_style(styles.list[((i - 1 + delta) % count) + 1].id)
            return
        end
    end
    apply_style(styles.list[1].id)
end

local function set_statusline_style(style_id)
    if not style_id or style_id == "" then
        return pick_style()
    elseif style_id == "next" then
        return step_style(1)
    elseif style_id == "prev" then
        return step_style(-1)
    end

    style_id = styles.aliases[tostring(style_id)] or tostring(style_id)
    if styles.lookup[style_id] then
        apply_style(style_id)
    else
        vim.notify("Unknown style: " .. tostring(style_id), vim.log.levels.WARN, { title = "Status Style" })
    end
end

local function create_commands()
    local ids = {}
    for _, s in ipairs(styles.list) do
        table.insert(ids, s.id)
    end
    table.insert(ids, "next")
    table.insert(ids, "prev")

    vim.api.nvim_create_user_command("StatusStyle", function(opts)
        set_statusline_style(opts.args)
    end, {
        nargs = "?",
        complete = function()
            return ids
        end,
        desc = "Switch Lualine + Barbar style",
    })

    vim.api.nvim_create_user_command("UISeparator", function(opts)
        local name = tostring(opts.args):lower()
        if not separators.nvchad[name] then
            vim.notify("Use: default, round, block, arrow", vim.log.levels.WARN, { title = "UI Separator" })
            return
        end

        vim.g.ui_nvchad_separator = name
        status_style.save_separator(name)
        apply()
        refresh_tabline()
        vim.notify("NvChad separator: " .. name, vim.log.levels.INFO, { title = "UI Separator" })
    end, {
        nargs = 1,
        complete = function()
            return { "default", "round", "block", "arrow" }
        end,
        desc = "Set shared NvChad separator style",
    })
end

function M.setup()
    create_commands()
    apply()

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("dynamic_lualine_theme", { clear = true }),
        callback = function()
            parts.reset_palette()
            apply()
            vim.schedule(refresh_tabline)
        end,
    })
end

return M
