local M = {}

local state_file = vim.fn.stdpath("state") .. "/status_style.json"

local function read_state()
    local file = io.open(state_file, "r")
    if not file then
        return {}
    end

    local content = file:read("*a")
    file:close()

    local ok, state = pcall(vim.json.decode, content)
    return ok and type(state) == "table" and state or {}
end

local function write_state(state)
    vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")

    local file = io.open(state_file, "w")
    if not file then
        vim.notify(
            "Could not persist status style settings",
            vim.log.levels.WARN,
            { title = "Status Style" }
        )
        return
    end

    file:write(vim.json.encode(state))
    file:close()
end

function M.load()
    local state = read_state()

    if type(state.style) == "string" then
        vim.g.lualine_color_style = state.style
    else
        vim.g.lualine_color_style = vim.g.lualine_color_style or "evil"
    end

    if type(state.separator) == "string" then
        vim.g.ui_nvchad_separator = state.separator
    else
        vim.g.ui_nvchad_separator = vim.g.ui_nvchad_separator or "round"
    end
end

function M.save_style(style)
    local state = read_state()
    state.style = style
    write_state(state)
end

function M.save_separator(separator)
    local state = read_state()
    state.separator = separator
    write_state(state)
end

return M
