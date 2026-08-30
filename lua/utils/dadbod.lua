local M = {}

local output_bufnr = nil
local output_winid = nil

function M.get_mysql_bin()
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

function M.get_databases()
    local bin = M.get_mysql_bin()
    local result = vim.fn.systemlist(bin .. " -u root -s -N -e 'SHOW DATABASES;'")
    local ignored = {
        information_schema = true,
        performance_schema = true,
        mysql = true,
        phpmyadmin = true,
        sys = true,
    }
    local databases = {}
    for _, db in ipairs(result) do
        local name = vim.trim(db)
        if name ~= "" and not ignored[name] then
            table.insert(databases, name)
        end
    end
    return databases
end

function M.select_database(callback)
    local databases = M.get_databases()

    if #databases == 0 then
        vim.notify("No databases found in MariaDB. Is XAMPP running?", vim.log.levels.WARN, { title = "Dadbod / SQL" })
        return
    end

    vim.ui.select(databases, {
        prompt = "Select MariaDB Database for Current File:",
        format_item = function(item)
            return "󰆼 " .. item
        end,
    }, function(choice)
        if choice then
            local bufnr = vim.api.nvim_get_current_buf()
            vim.b[bufnr].db = "mariadb://root@127.0.0.1:3306/" .. choice
            pcall(vim.fn["vim_dadbod_completion#fetch"], bufnr)
            vim.notify("Connected to: " .. choice, vim.log.levels.INFO, { title = "Dadbod / SQL" })
            if callback then
                callback(choice)
            end
        end
    end)
end

function M.view_table_schema()
    local bufnr = vim.api.nvim_get_current_buf()
    local db_url = vim.b[bufnr].db or vim.g.db or ""
    local db_name = db_url:match("mariadb://[^/]+/([^?]+)") or db_url:match("mysql://[^/]+/([^?]+)")
    local bin = M.get_mysql_bin()

    local function show_schema_for_db(selected_db)
        local cmd = string.format("%s -u root -D %s -s -N -e 'SHOW TABLES;'", bin, vim.fn.shellescape(selected_db))
        local tables = vim.fn.systemlist(cmd)
        if #tables == 0 then
            vim.notify("No tables found in " .. selected_db, vim.log.levels.WARN, { title = "Schema Viewer" })
            return
        end

        vim.ui.select(tables, {
            prompt = "Select Table to View Schema (" .. selected_db .. "):",
            format_item = function(item)
                return "󰓫 " .. item
            end,
        }, function(table_name)
            if not table_name then return end
            local desc_cmd = string.format("%s -u root -D %s -t -e %s", bin, vim.fn.shellescape(selected_db), vim.fn.shellescape("DESCRIBE `" .. table_name .. "`;"))
            local schema = vim.fn.systemlist(desc_cmd)

            local float_buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, schema)
            vim.bo[float_buf].buftype = "nofile"
            vim.bo[float_buf].bufhidden = "wipe"
            vim.bo[float_buf].filetype = "markdown"

            local width = 0
            for _, line in ipairs(schema) do
                if #line > width then width = #line end
            end
            width = math.min(math.max(width + 4, 65), vim.o.columns - 4)
            local height = math.min(#schema + 2, vim.o.lines - 4)

            local win = vim.api.nvim_open_win(float_buf, true, {
                relative = "editor",
                width = width,
                height = height,
                col = math.floor((vim.o.columns - width) / 2),
                row = math.floor((vim.o.lines - height) / 2),
                style = "minimal",
                border = "rounded",
                title = " 󰆼 Schema: " .. selected_db .. "." .. table_name .. " (q to close) ",
                title_pos = "center",
            })

            vim.keymap.set("n", "q", function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = float_buf, silent = true })
            vim.keymap.set("n", "<Esc>", function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = float_buf, silent = true })
        end)
    end

    if db_name and db_name ~= "" then
        show_schema_for_db(db_name)
    else
        M.select_database(function(choice)
            if choice then
                show_schema_for_db(choice)
            end
        end)
    end
end

-- Extract current statement around cursor in normal mode (delimited by semicolon or blank lines)
local function get_current_statement()
    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)
    local all_lines = vim.api.nvim_buf_get_lines(0, 0, total_lines, false)

    -- Scan backwards to find the start of the current statement
    local start_line = cur_line
    while start_line > 1 do
        local prev_text = vim.trim(all_lines[start_line - 1] or "")
        if prev_text:sub(-1) == ";" then
            break
        end
        start_line = start_line - 1
    end

    -- Scan forwards to find the end of the current statement
    local end_line = cur_line
    while end_line <= total_lines do
        local line_text = vim.trim(all_lines[end_line] or "")
        if line_text:sub(-1) == ";" or end_line == total_lines then
            break
        end
        end_line = end_line + 1
    end

    local statement_lines = {}
    for i = start_line, end_line do
        table.insert(statement_lines, all_lines[i])
    end

    local result = table.concat(statement_lines, "\n")
    if vim.trim(result) == "" then
        -- Fallback to whole buffer if empty
        return table.concat(all_lines, "\n")
    end
    return result
end

local function get_sql_text(mode)
    if mode == "v" or mode == "V" or mode == "\22" then
        -- Visual selection
        local _, srow, scol = unpack(vim.fn.getpos("'<"))
        local _, erow, ecol = unpack(vim.fn.getpos("'>"))
        if srow > erow or (srow == erow and scol > ecol) then
            srow, erow = erow, srow
            scol, ecol = ecol, scol
        end
        local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
        if #lines == 0 then return "" end
        if #lines == 1 then
            lines[1] = string.sub(lines[1], scol, ecol)
        else
            lines[1] = string.sub(lines[1], scol)
            lines[#lines] = string.sub(lines[#lines], 1, ecol)
        end
        return table.concat(lines, "\n")
    else
        -- Normal mode: execute current statement / query under cursor
        return get_current_statement()
    end
end

function M.run_sql(mode)
    local cur_win = vim.api.nvim_get_current_win()
    local cur_buf = vim.api.nvim_get_current_buf()

    local db_url = vim.b[cur_buf].db or vim.g.db or vim.env.DATABASE_URL or ""
    local db_name = db_url:match("mariadb://[^/]+/([^?]+)") or db_url:match("mysql://[^/]+/([^?]+)")

    if not db_name or db_name == "" then
        M.select_database(function()
            vim.schedule(function()
                M.run_sql(mode)
            end)
        end)
        return
    end

    local sql = get_sql_text(mode)
    if not sql or vim.trim(sql) == "" then
        vim.notify("SQL query is empty", vim.log.levels.WARN, { title = "Dadbod / SQL" })
        return
    end

    local bin = M.get_mysql_bin()
    local start_time = vim.uv.hrtime()
    local cmd = { bin, "-u", "root", "-D", db_name, "-t", "-e", sql }

    vim.notify("Executing query on [" .. db_name .. "]... 󱐌", vim.log.levels.INFO, { title = "SQL Runner" })

    -- Run query asynchronously via vim.system to prevent freezing Neovim
    vim.system(cmd, { text = true }, function(obj)
        local duration = (vim.uv.hrtime() - start_time) / 1e6

        vim.schedule(function()
            -- Create or reuse output buffer
            if not output_bufnr or not vim.api.nvim_buf_is_valid(output_bufnr) then
                output_bufnr = vim.api.nvim_create_buf(false, true)
                vim.bo[output_bufnr].buftype = "nofile"
                vim.bo[output_bufnr].bufhidden = "hide"
                vim.bo[output_bufnr].filetype = "dbout"
                pcall(vim.api.nvim_buf_set_name, output_bufnr, "[SQL Output]")

                local function close_output()
                    if output_winid and vim.api.nvim_win_is_valid(output_winid) then
                        if #vim.api.nvim_tabpage_list_wins(0) > 1 then
                            pcall(vim.api.nvim_win_close, output_winid, true)
                        end
                    end
                end
                vim.keymap.set("n", "q", close_output, { buffer = output_bufnr, silent = true, desc = "Close SQL Output" })
                vim.keymap.set("n", "<Esc>", close_output, { buffer = output_bufnr, silent = true, desc = "Close SQL Output" })
            end

            local out_text = obj.stdout or ""
            local err_text = obj.stderr or ""
            local is_error = (obj.code ~= 0)

            local header = {
                string.format("/* Database: %s | Client: %s | Time: %.2f ms | Status: %s */",
                    db_name,
                    vim.fn.fnamemodify(bin, ":t"),
                    duration,
                    is_error and "ERROR (" .. obj.code .. ")" or "SUCCESS"
                ),
                "",
            }

            local all_lines = {}
            for _, h in ipairs(header) do table.insert(all_lines, h) end

            if is_error and err_text ~= "" then
                for line in err_text:gmatch("[^\r\n]+") do
                    table.insert(all_lines, line)
                end
            elseif out_text ~= "" then
                for line in out_text:gmatch("[^\r\n]+") do
                    table.insert(all_lines, line)
                end
            else
                table.insert(all_lines, "Query OK (Empty result set / 0 rows affected)")
            end

            vim.bo[output_bufnr].modifiable = true
            vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, all_lines)
            vim.bo[output_bufnr].modifiable = false

            -- Display in split window
            if not output_winid or not vim.api.nvim_win_is_valid(output_winid) then
                vim.cmd("botright 14split")
                output_winid = vim.api.nvim_get_current_win()
                vim.api.nvim_win_set_buf(output_winid, output_bufnr)
            else
                vim.api.nvim_win_set_buf(output_winid, output_bufnr)
            end

            -- Keep focus in the code editor window so the user can continue typing immediately
            if cur_win and vim.api.nvim_win_is_valid(cur_win) then
                pcall(vim.api.nvim_set_current_win, cur_win)
            end

            if is_error then
                vim.notify("SQL Query failed. See [SQL Output] panel.", vim.log.levels.ERROR, { title = "SQL Runner" })
            else
                vim.notify(string.format("Query executed in %.2f ms ", duration), vim.log.levels.INFO, { title = "SQL Runner" })
            end
        end)
    end)
end

return M
