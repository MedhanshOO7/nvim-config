-- ============================================================================
-- SQL Schema Sidebar / Viewer
-- ============================================================================
-- A configurable, persistent schema viewer for SQL buffers. It can be shown
-- as a sidebar (left/right), a bottom split, or a floating window, and uses
-- snacks.picker for table/column selection so you never forget your schema.
--
-- Configuration (set in init.lua before plugins load):
--   vim.g.sql_schema = {
--     position = "sidebar",   -- "sidebar" | "float" | "bottom" | "right"
--     sidebar_side = "left",  -- "left" | "right" (only for position = "sidebar")
--     width = 35,             -- width for sidebar / right / float
--     height = 12,            -- height for bottom / float
--     auto_open = false,      -- open automatically on SQL filetype
--     db_url = nil,           -- override detected DB URL
--   }
-- ============================================================================

local M = {}

-- Default configuration.
local config = {
    position = "sidebar",
    sidebar_side = "left",
    width = 35,
    height = 12,
    auto_open = false,
    db_url = nil,
}

-- Persistent window state.
local schema_bufnr = nil
local schema_winid = nil
local is_visible = false

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function get_db_name()
    local bufnr = vim.api.nvim_get_current_buf()
    local db_url = config.db_url or vim.b[bufnr].db or vim.g.db or vim.env.DATABASE_URL or ""
    local name = db_url:match("mariadb://[^/]+/([^?]+)")
        or db_url:match("mysql://[^/]+/([^?]+)")
        or db_url:match("postgres://[^/]+/([^?]+)")
    return name, db_url
end

local function get_mysql_bin()
    local xampp_mysql = "/opt/lampp/bin/mysql"
    if vim.fn.executable(xampp_mysql) == 1 then
        return xampp_mysql
    elseif vim.fn.executable("mariadb") == 1 then
        return "mariadb"
    elseif vim.fn.executable("mysql") == 1 then
        return "mysql"
    end
    return "mysql"
end

local function ensure_schema_buf()
    if schema_bufnr and vim.api.nvim_buf_is_valid(schema_bufnr) then
        return schema_bufnr
    end
    schema_bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[schema_bufnr].buftype = "nofile"
    vim.bo[schema_bufnr].bufhidden = "hide"
    vim.bo[schema_bufnr].filetype = "sql-schema"
    vim.bo[schema_bufnr].modifiable = false
    return schema_bufnr
end

local function close_schema_win()
    if schema_winid and vim.api.nvim_win_is_valid(schema_winid) then
        pcall(vim.api.nvim_win_close, schema_winid, true)
    end
    schema_winid = nil
    is_visible = false
end

local function win_opts_for_position(pos, side, width, height)
    local cols = vim.o.columns
    local lines = vim.o.lines

    if pos == "sidebar" or pos == "right" then
        local col = (side == "right") and (cols - width) or 0
        return {
            relative = "editor",
            width = width,
            height = lines - 4,
            col = col,
            row = 2,
            style = "minimal",
            border = "rounded",
        }
    elseif pos == "bottom" then
        local row = lines - height - 2
        return {
            relative = "editor",
            width = cols - 4,
            height = height,
            col = 2,
            row = row,
            style = "minimal",
            border = "rounded",
        }
    elseif pos == "float" then
        local w = math.min(width, cols - 4)
        local h = math.min(height, lines - 4)
        return {
            relative = "editor",
            width = w,
            height = h,
            col = math.floor((cols - w) / 2),
            row = math.floor((lines - h) / 2),
            style = "minimal",
            border = "rounded",
        }
    end
    -- default: sidebar left
    return {
        relative = "editor",
        width = width,
        height = lines - 4,
        col = 0,
        row = 2,
        style = "minimal",
        border = "rounded",
    }
end

-- ---------------------------------------------------------------------------
-- Schema fetching
-- ---------------------------------------------------------------------------

function M.get_tables(db_name)
    local bin = get_mysql_bin()
    local cmd = string.format("%s -u root -D %s -s -N -e 'SHOW TABLES;'", bin, vim.fn.shellescape(db_name))
    local result = vim.fn.systemlist(cmd)
    local tables = {}
    for _, t in ipairs(result) do
        local n = vim.trim(t)
        if n ~= "" then
            table.insert(tables, n)
        end
    end
    return tables
end

function M.get_columns(db_name, table_name)
    local bin = get_mysql_bin()
    local cmd = string.format(
        "%s -u root -D %s -t -e %s",
        bin,
        vim.fn.shellescape(db_name),
        vim.fn.shellescape("DESCRIBE `" .. table_name .. "`;")
    )
    local result = vim.fn.systemlist(cmd)
    -- Skip the header and separator lines from DESCRIBE output.
    local columns = {}
    for _, line in ipairs(result) do
        if line:find("^%+") or line:find("^Field") or line:find("^%s*$") then
            goto continue
        end
        local col = line:match("^%s*([^%s|]+)")
        if col then
            table.insert(columns, col)
        end
        ::continue::
    end
    return columns
end

-- ---------------------------------------------------------------------------
-- Render schema into the persistent buffer
-- ---------------------------------------------------------------------------

function M.render_schema()
    local buf = ensure_schema_buf()
    local db_name, _ = get_db_name()

    if not db_name or db_name == "" then
        local lines = {
            "  SQL Schema Viewer",
            "  ─────────────────",
            "",
            "  No database connected.",
            "  Press <leader>Ds to select a database,",
            "  or <leader>DS to open the schema viewer.",
        }
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        return
    end

    local ok, tables = pcall(M.get_tables, db_name)
    if not ok or #tables == 0 then
        local lines = {
            "  SQL Schema Viewer — " .. db_name,
            "  ─────────────────────────────",
            "",
            "  No tables found.",
        }
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        return
    end

    local lines = {}
    table.insert(lines, "  SQL Schema — " .. db_name)
    table.insert(lines, "  " .. string.rep("─", 40))
    table.insert(lines, "")

    for _, table_name in ipairs(tables) do
        table.insert(lines, "  󰓫 " .. table_name)
        local ok2, columns = pcall(M.get_columns, db_name, table_name)
        if ok2 and #columns > 0 then
            for _, col in ipairs(columns) do
                table.insert(lines, "    ├─ " .. col)
            end
        else
            table.insert(lines, "    (could not read columns)")
        end
        table.insert(lines, "")
    end

    table.insert(lines, "  ─────────────────────────────")
    table.insert(lines, "  Press <leader>DS to refresh / reopen")
    table.insert(lines, "  Press q to close this view")

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
end

-- ---------------------------------------------------------------------------
-- Open / toggle the schema view
-- ---------------------------------------------------------------------------

function M.open()
    local pos = config.position
    local side = config.sidebar_side
    local width = config.width
    local height = config.height

    local buf = ensure_schema_buf()
    M.render_schema()

    -- Reuse existing window if valid and visible.
    if schema_winid and vim.api.nvim_win_is_valid(schema_winid) then
        vim.api.nvim_win_set_buf(schema_winid, buf)
        vim.api.nvim_set_current_win(schema_winid)
        is_visible = true
        return
    end

    local opts = win_opts_for_position(pos, side, width, height)
    opts.title = " 󰆼 SQL Schema (" .. pos .. ") "
    opts.title_pos = "center"

    schema_winid = vim.api.nvim_open_win(buf, true, opts)
    vim.wo[schema_winid].wrap = false
    vim.wo[schema_winid].number = false
    vim.wo[schema_winid].relativenumber = false
    vim.wo[schema_winid].cursorline = false

    -- q / <Esc> to close.
    vim.keymap.set("n", "q", function()
        close_schema_win()
    end, { buffer = buf, silent = true, desc = "Close SQL schema view" })
    vim.keymap.set("n", "<Esc>", function()
        close_schema_win()
    end, { buffer = buf, silent = true, desc = "Close SQL schema view" })

    -- r to refresh.
    vim.keymap.set("n", "r", function()
        M.render_schema()
        vim.notify("SQL schema refreshed", vim.log.levels.INFO, { title = "SQL Schema" })
    end, { buffer = buf, silent = true, desc = "Refresh SQL schema" })

    is_visible = true
end

function M.toggle()
    if is_visible and schema_winid and vim.api.nvim_win_is_valid(schema_winid) then
        close_schema_win()
    else
        M.open()
    end
end

function M.close()
    close_schema_win()
end

-- ---------------------------------------------------------------------------
-- snacks.picker integration: pick a table, then show its columns in a picker
-- ---------------------------------------------------------------------------

function M.pick_table()
    local db_name, _ = get_db_name()
    if not db_name or db_name == "" then
        vim.notify("No database connected. Use <leader>Ds to select one.", vim.log.levels.WARN, { title = "SQL Schema" })
        return
    end

    local ok, tables = pcall(M.get_tables, db_name)
    if not ok or #tables == 0 then
        vim.notify("No tables found in " .. db_name, vim.log.levels.WARN, { title = "SQL Schema" })
        return
    end

    local Snacks_ok, Snacks = pcall(require, "snacks")
    if not Snacks_ok then
        vim.notify("snacks.nvim not available for picker", vim.log.levels.ERROR, { title = "SQL Schema" })
        return
    end

    Snacks.picker.pick({
        items = tables,
        prompt = "Select Table (" .. db_name .. "):",
        format = function(item)
            return { { "󰓫 ", "SnacksPickerIcon" }, { item } }
        end,
        actions = {
            pick_columns = function(picker)
                local selected = picker:selected()
                if #selected == 0 then return end
                local table_name = selected[1].text or selected[1]
                M.pick_columns(db_name, table_name)
                picker:close()
            end,
            open_sidebar = function(picker)
                local selected = picker:selected()
                if #selected == 0 then return end
                picker:close()
                M.open()
            end,
        },
        win = {
            input = {
                keys = {
                    ["<cr>"] = { "pick_columns", mode = { "n", "i" } },
                    ["s"] = { "open_sidebar", mode = { "n", "i" } },
                },
            },
        },
    }, function(_, item)
        if item then
            M.pick_columns(db_name, item.text or item)
        end
    end)
end

function M.pick_columns(db_name, table_name)
    local ok, columns = pcall(M.get_columns, db_name, table_name)
    if not ok or #columns == 0 then
        vim.notify("No columns found for " .. table_name, vim.log.levels.WARN, { title = "SQL Schema" })
        return
    end

    local Snacks_ok, Snacks = pcall(require, "snacks")
    if not Snacks_ok then
        -- Fallback: just show in the sidebar buffer.
        local lines = { "  Columns for " .. table_name .. " (" .. db_name .. ")", "  " .. string.rep("─", 40), "" }
        for _, col in ipairs(columns) do
            table.insert(lines, "  ├─ " .. col)
        end
        M.render_schema() -- ensure schema buf exists
        vim.bo[schema_bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(schema_bufnr, 0, -1, false, lines)
        vim.bo[schema_bufnr].modifiable = false
        M.open()
        return
    end

    Snacks.picker.pick({
        items = columns,
        prompt = "Columns — " .. table_name .. " (" .. db_name .. "):",
        format = function(item)
            return { { "󰆦 ", "SnacksPickerIcon" }, { item } }
        end,
        actions = {
            insert_column = function(picker)
                local selected = picker:selected()
                if #selected == 0 then return end
                local col = selected[1].text or selected[1]
                picker:close()
                -- Insert the column name at cursor in the current SQL buffer.
                local bufnr = vim.api.nvim_get_current_buf()
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { col })
                vim.notify("Inserted column: " .. col, vim.log.levels.INFO, { title = "SQL Schema" })
            end,
        },
        win = {
            input = {
                keys = {
                    ["<cr>"] = { "insert_column", mode = { "n", "i" } },
                },
            },
        },
    }, function(_, item)
        if item then
            local col = item.text or item
            local bufnr = vim.api.nvim_get_current_buf()
            local row, c = unpack(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_buf_set_text(bufnr, row - 1, c, row - 1, c, { col })
            vim.notify("Inserted column: " .. col, vim.log.levels.INFO, { title = "SQL Schema" })
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Autocmd: auto-open on SQL filetype if configured
-- ---------------------------------------------------------------------------

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})

    -- Auto-open on SQL filetype.
    if config.auto_open then
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "sql", "mysql", "plsql" },
            callback = function()
                -- Only auto-open if no schema window is already open.
                if not is_visible then
                    vim.defer_fn(function()
                        if vim.bo.filetype:match("sql") then
                            M.open()
                        end
                    end, 100)
                end
            end,
        })
    end

    -- Expose commands.
    vim.api.nvim_create_user_command("SQLSchema", function()
        M.toggle()
    end, { desc = "Toggle SQL schema sidebar/viewer" })

    vim.api.nvim_create_user_command("SQLSchemaOpen", function()
        M.open()
    end, { desc = "Open SQL schema sidebar/viewer" })

    vim.api.nvim_create_user_command("SQLSchemaClose", function()
        M.close()
    end, { desc = "Close SQL schema sidebar/viewer" })

    vim.api.nvim_create_user_command("SQLSchemaPick", function()
        M.pick_table()
    end, { desc = "Pick a table via snacks.picker and view columns" })
end

return M
