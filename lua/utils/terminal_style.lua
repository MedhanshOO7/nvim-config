local M = {}

local state_file = vim.fn.stdpath("state") .. "/terminal_style.json"

M.styles = {
    { id = "float",      name = "Floating Window (Center Modal)", icon = "󰹚 ", direction = "float" },
    { id = "horizontal", name = "Bottom Panel (Below Split)",     icon = "󰤻 ", direction = "horizontal" },
    { id = "right",      name = "Right Panel (Right Split)",      icon = "󰤼 ", direction = "vertical" },
}

local function read_state()
    local f = io.open(state_file, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    local ok, parsed = pcall(vim.json.decode, content)
    if ok and type(parsed) == "table" then
        return parsed
    end
end

local function write_state(style_id)
    local f = io.open(state_file, "w")
    if f then
        f:write(vim.json.encode({ style = style_id }))
        f:close()
    end
end

function M.get_current_style()
    return vim.g.preferred_terminal_style or "float"
end

function M.get_direction()
    local style = M.get_current_style()
    if style == "horizontal" then
        return "horizontal"
    elseif style == "right" then
        vim.opt.splitright = true
        return "vertical"
    else
        return "float"
    end
end

function M.toggle()
    local dir = M.get_direction()
    local ok_terms, terms = pcall(require, "toggleterm.terminal")
    if ok_terms and terms.get_all then
        local term = terms.get(1, true)
        if term then
            if term:is_open() then
                term:close()
                return
            else
                if term.direction ~= dir then
                    term:change_direction(dir)
                end
                term:open(nil, dir)
                return
            end
        end
    end

    local ok_tt, tt = pcall(require, "toggleterm")
    if ok_tt then
        tt.toggle(1, nil, nil, dir, "Terminal")
    else
        vim.cmd("ToggleTerm")
    end
end

function M.apply(style_id, notify)
    local target
    for _, s in ipairs(M.styles) do
        if s.id == style_id then
            target = s
            break
        end
    end
    if not target then
        target = M.styles[1]
    end

    vim.g.preferred_terminal_style = target.id
    write_state(target.id)

    local direction = target.direction
    if target.id == "right" then
        direction = "vertical"
        vim.opt.splitright = true
    end

    -- 1. Configure ToggleTerm default direction
    local ok_tt, tt = pcall(require, "toggleterm")
    if ok_tt then
        tt.setup({
            direction = direction,
        })

        -- 2. Update all existing active terminal instances in memory
        local ok_terms, terms = pcall(require, "toggleterm.terminal")
        if ok_terms and terms.get_all then
            for _, term in pairs(terms.get_all(true)) do
                if term:is_open() then
                    term:close()
                end
                term:change_direction(direction)
            end
        end
    end

    -- 3. Configure Code Runner mode to toggleterm if code_runner is active
    if package.loaded["code_runner"] then
        local ok_cr, cr = pcall(require, "code_runner")
        if ok_cr then
            cr.setup({
                mode = "toggleterm",
            })
        end
    end

    if notify ~= false then
        vim.notify(string.format("%s Terminal & Runner: %s", target.icon, target.name), vim.log.levels.INFO, {
            title = "Terminal Style",
        })
    end
end

function M.select()
    local items = {}
    local current = M.get_current_style()

    for _, s in ipairs(M.styles) do
        local is_active = (s.id == current)
        table.insert(items, {
            id = s.id,
            name = s.name,
            icon = s.icon,
            label = string.format("%s  %-30s%s", s.icon, s.name, is_active and "  (active)" or ""),
        })
    end

    vim.ui.select(items, {
        prompt = "Select Terminal & Code Runner Style:",
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice and choice.id then
            M.apply(choice.id)
        end
    end)
end

function M.setup()
    local saved = read_state()
    local initial = saved and saved.style or "float"
    M.apply(initial, false)

    vim.api.nvim_create_user_command("TerminalStyle", function()
        M.select()
    end, { desc = "Select Terminal and Code Runner Style" })
end

return M
