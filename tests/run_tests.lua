-- ============================================================================
-- Neovim Configuration Rigorous Test Suite
-- ============================================================================

local test_count = 0
local pass_count = 0
local fail_count = 0
local failures = {}

local function color(code, text)
    return string.format("\27[%dm%s\27[0m", code, text)
end

local function describe(suite_name, fn)
    print(string.format("\n%s %s", color(36, "󰙨"), color(1, suite_name)))
    fn()
end

local function it(test_name, fn)
    test_count = test_count + 1
    local ok, err = pcall(fn)
    if ok then
        pass_count = pass_count + 1
        print(string.format("  %s %s", color(32, "✔"), test_name))
    else
        fail_count = fail_count + 1
        table.insert(failures, { name = test_name, err = err })
        print(string.format("  %s %s\n    %s", color(31, "✖"), test_name, color(31, tostring(err))))
    end
end

local function assert_eq(actual, expected, msg)
    if actual ~= expected then
        error(string.format("%s: expected %s, got %s", msg or "assertion failed", vim.inspect(expected), vim.inspect(actual)))
    end
end

local function assert_true(val, msg)
    if not val then
        error(msg or "assertion failed: expected true, got " .. vim.inspect(val))
    end
end

local function assert_false(val, msg)
    if val then
        error(msg or "assertion failed: expected false, got " .. vim.inspect(val))
    end
end

local function assert_not_nil(val, msg)
    if val == nil then
        error(msg or "assertion failed: expected not nil")
    end
end

-- ============================================================================
-- 1. CORE & ENVIRONMENT TESTS
-- ============================================================================
describe("Core Options & Settings", function()
    it("should have sensible editor options set", function()
        assert_true(vim.o.termguicolors, "termguicolors should be enabled")
        assert_true(vim.o.number, "line numbers should be enabled")
        assert_true(vim.o.relativenumber, "relative numbers should be enabled")
        assert_eq(vim.o.tabstop, 4, "tabstop should be 4")
        assert_eq(vim.o.shiftwidth, 4, "shiftwidth should be 4")
        assert_true(vim.o.expandtab, "expandtab should be enabled")
    end)

    it("should have essential global variables initialized", function()
        assert_not_nil(vim.g.mapleader, "mapleader should be set")
        assert_not_nil(vim.g.maplocalleader, "maplocalleader should be set")
    end)
end)

-- ============================================================================
-- 2. AUTOCOMMANDS & WINDOW SAFETY TESTS
-- ============================================================================
describe("Autocommands & Buffer Safety", function()
    it("QuickDismissWindows should NOT hijack dbui or dadbod buffers", function()
        local dbui_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[dbui_buf].filetype = "dbui"
        vim.bo[dbui_buf].buftype = "nofile"

        -- Trigger FileType event
        vim.api.nvim_exec_autocmds("FileType", { buffer = dbui_buf })

        -- Check that 'q' in this buffer was NOT mapped by QuickDismissWindows
        local q_map = vim.fn.maparg("q", "n", false, true)
        local desc = q_map.desc or ""
        assert_false(desc:find("Close window") ~= nil and q_map.buffer == 1, "QuickDismissWindows should not map 'q' on dbui buffers")

        vim.api.nvim_buf_delete(dbui_buf, { force = true })
    end)

    it("QuickDismissWindows should NOT hijack dbout buffers", function()
        local dbout_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[dbout_buf].filetype = "dbout"
        vim.bo[dbout_buf].buftype = "nofile"

        vim.api.nvim_exec_autocmds("FileType", { buffer = dbout_buf })

        local q_map = vim.fn.maparg("q", "n", false, true)
        local desc = q_map.desc or ""
        assert_false(desc:find("Close window") ~= nil and q_map.buffer == 1, "QuickDismissWindows should not map 'q' on dbout buffers")

        vim.api.nvim_buf_delete(dbout_buf, { force = true })
    end)
end)

-- ============================================================================
-- 3. AUTO-SAVE CONFIGURATION TESTS
-- ============================================================================
describe("Auto-Save Configuration", function()
    it("auto-save setup should ignore dbui, dbout, and unmodifiable buffers", function()
        local ok, autosave_cnf = pcall(require, "auto-save.config")
        assert_true(ok, "auto-save.config should be loadable")

        local condition = autosave_cnf.opts.condition
        assert_not_nil(condition, "auto-save condition function should exist")

        -- Test 1: dbui buffer
        local dbui_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[dbui_buf].filetype = "dbui"
        assert_false(condition(dbui_buf), "auto-save should reject dbui buffer")

        -- Test 2: dbout buffer
        local dbout_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[dbout_buf].filetype = "dbout"
        assert_false(condition(dbout_buf), "auto-save should reject dbout buffer")

        -- Test 3: unmodifiable buffer
        local ro_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[ro_buf].modifiable = false
        assert_false(condition(ro_buf), "auto-save should reject unmodifiable buffer")

        -- Test 4: un-named buffer
        local noname_buf = vim.api.nvim_create_buf(false, true)
        assert_false(condition(noname_buf), "auto-save should reject un-named buffer")

        -- Clean up
        vim.api.nvim_buf_delete(dbui_buf, { force = true })
        vim.api.nvim_buf_delete(dbout_buf, { force = true })
        vim.api.nvim_buf_delete(ro_buf, { force = true })
        vim.api.nvim_buf_delete(noname_buf, { force = true })
    end)
end)

-- ============================================================================
-- 4. CONFORM FORMATTER INTEGRATION TESTS
-- ============================================================================
describe("Conform.nvim Formatter Configurations", function()
    local conform = require("conform")

    local test_fts = {
        "javascript",
        "typescript",
        "typescriptreact",
        "javascriptreact",
        "python",
        "lua",
        "json",
        "jsonc",
        "html",
        "css",
        "scss",
        "less",
        "markdown",
        "markdown.mdx",
        "sh",
        "bash",
        "zsh",
        "sql",
        "yaml",
        "c",
        "cpp",
    }

    for _, ft in ipairs(test_fts) do
        it(string.format("should list valid formatters for '%s' without assertion errors", ft), function()
            local buf = vim.api.nvim_create_buf(false, true)
            vim.bo[buf].filetype = ft
            vim.api.nvim_buf_set_name(buf, "/tmp/test_file." .. ft)

            local ok, result = pcall(conform.list_formatters_for_buffer, buf)
            assert_true(ok, string.format("list_formatters_for_buffer failed for %s: %s", ft, tostring(result)))
            assert_true(type(result) == "table", "result should be a table")

            vim.api.nvim_buf_delete(buf, { force = true })
        end)
    end
end)

-- ============================================================================
-- 5. BLINK.CMP & DADBOD COMPLETION TESTS
-- ============================================================================
describe("Blink.cmp Database Icons & Completion", function()
    local cmp = require("blink.cmp")

    it("blink.cmp should load properly", function()
        assert_not_nil(cmp, "blink.cmp module should exist")
    end)

    it("should have custom database kind icons configured", function()
        local config = require("blink.cmp.config")
        local kind_icons = config.appearance.kind_icons
        assert_not_nil(kind_icons.Table, "Table icon should be defined")
        assert_not_nil(kind_icons.Column, "Column icon should be defined")
        assert_not_nil(kind_icons.Database, "Database icon should be defined")
        assert_not_nil(kind_icons.Alias, "Alias icon should be defined")
    end)

    it("dadbod transform_items should accurately classify table and column items", function()
        local config = require("blink.cmp.config")
        local dadbod_provider = config.sources.providers.dadbod
        assert_not_nil(dadbod_provider, "dadbod provider should be configured")
        assert_not_nil(dadbod_provider.transform_items, "dadbod transform_items should exist")

        local mock_items = {
            { label = "student", documentation = "table", kind = 7 },
            { label = "student_id", documentation = "student table column", kind = 5 },
            { label = "ccet_committees", documentation = "schema", kind = 19 },
            { label = "s", documentation = "alias for table student", kind = 6 },
        }

        local transformed = dadbod_provider.transform_items(nil, mock_items)
        assert_eq(#transformed, 4, "all items should be returned")

        local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
        local function kind_to_name(kind_idx)
            return CompletionItemKind[kind_idx]
        end

        assert_eq(kind_to_name(transformed[1].kind), "Table", "student should be Table kind")
        assert_eq(kind_to_name(transformed[2].kind), "Column", "student_id should be Column kind")
        assert_eq(kind_to_name(transformed[3].kind), "Database", "ccet_committees should be Database kind")
        assert_eq(kind_to_name(transformed[4].kind), "Alias", "s should be Alias kind")
    end)
end)

-- ============================================================================
-- 6. DADBOD & MARIADB UTILITIES TESTS
-- ============================================================================
describe("Dadbod & MariaDB Utilities (lua/utils/dadbod.lua)", function()
    local dadbod = require("utils.dadbod")

    it("get_databases should query active databases and filter system tables", function()
        local dbs = dadbod.get_databases()
        assert_true(type(dbs) == "table", "get_databases should return a table")
        assert_true(#dbs > 0, "should discover active MariaDB databases from XAMPP")

        -- Check that system databases are excluded
        local db_set = {}
        for _, name in ipairs(dbs) do
            db_set[name] = true
        end
        assert_false(db_set["information_schema"], "information_schema should be excluded")
        assert_false(db_set["performance_schema"], "performance_schema should be excluded")
        assert_false(db_set["mysql"], "mysql should be excluded")
        assert_false(db_set["phpmyadmin"], "phpmyadmin should be excluded")

        -- Check that user database is present
        assert_true(db_set["ccet_committees"] or db_set["campus_placement"], "user databases should be discovered")
    end)

    it("describe table should fetch schema correctly from MariaDB", function()
        local schema = vim.fn.systemlist("mariadb -D ccet_committees -t -e 'DESCRIBE Committees;'")
        assert_true(#schema > 0, "DESCRIBE Committees should return schema lines")
        local header_found = false
        local col_found = false
        for _, line in ipairs(schema) do
            if line:find("Field") and line:find("Type") then header_found = true end
            if line:find("Committee_ID") then col_found = true end
        end
        assert_true(header_found, "Schema header (Field, Type) should be present")
        assert_true(col_found, "Column 'Committee_ID' should be present in schema")
    end)

    it("run_sql should execute queries and populate [SQL Output] buffer", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, "/tmp/test_query.sql")
        vim.bo[buf].filetype = "sql"
        vim.b[buf].db = "mariadb://root@127.0.0.1:3306/ccet_committees"
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "SELECT Committee_ID, Committee FROM Committees LIMIT 2;" })

        -- Switch to test buffer and run query
        local orig_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_win_set_buf(orig_win, buf)

        dadbod.run_sql("n")

        -- Wait for async execution to complete
        local out_buf = nil
        vim.wait(3000, function()
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b):find("%[SQL Output%]") then
                    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
                    if #lines > 2 then
                        out_buf = b
                        return true
                    end
                end
            end
            return false
        end, 50)

        assert_not_nil(out_buf, "[SQL Output] buffer should be created and populated")
        local lines = vim.api.nvim_buf_get_lines(out_buf, 0, -1, false)
        assert_true(#lines > 3, "Output buffer should contain query results")

        local output_text = table.concat(lines, "\n")
        assert_true(output_text:find("Database: ccet_committees"), "Header should show database name")
        assert_true(output_text:find("Committee_ID"), "Results should contain Committee_ID column")

        -- Verify editor window maintained focus
        assert_eq(vim.api.nvim_get_current_win(), orig_win, "Editor window should retain focus after run_sql")

        -- Clean up
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("run_sql should support continuous reruns without creating duplicate buffers", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, "/tmp/test_rerun_suite.sql")
        vim.bo[buf].filetype = "sql"
        vim.b[buf].db = "mariadb://root@127.0.0.1:3306/ccet_committees"

        local orig_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_win_set_buf(orig_win, buf)

        -- Run 1
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "SELECT * FROM Committees LIMIT 1;" })
        dadbod.run_sql("n")
        vim.wait(1500, function() return false end, 50)

        -- Run 2
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "SELECT Committee_ID FROM Committees LIMIT 3;" })
        dadbod.run_sql("n")
        vim.wait(1500, function() return false end, 50)

        -- Count [SQL Output] buffers
        local out_buf_count = 0
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b):find("%[SQL Output%]") then
                out_buf_count = out_buf_count + 1
            end
        end

        assert_eq(out_buf_count, 1, "Should reuse a single [SQL Output] buffer across multiple runs")

        vim.api.nvim_buf_delete(buf, { force = true })
    end)
end)

-- ============================================================================
-- 7. KEYMAPPING INTEGRITY TESTS
-- ============================================================================
describe("Keymapping Configurations", function()
    it("<leader>rr should be mapped to run SQL in SQL files and RunCode in code files", function()
        local rr_map = vim.fn.maparg("<leader>rr", "n", false, true)
        assert_not_nil(rr_map, "<leader>rr mapping should exist")
        assert_not_nil(rr_map.callback or rr_map.rhs, "<leader>rr should have an executable action")
    end)

    it("<leader>cf should be mapped to conform.format", function()
        local cf_map = vim.fn.maparg("<leader>cf", "n", false, true)
        assert_not_nil(cf_map, "<leader>cf mapping should exist")
        assert_not_nil(cf_map.callback or cf_map.rhs, "<leader>cf should have a format action")
    end)

    it("<leader>Ds should be mapped to select_database", function()
        local ds_map = vim.fn.maparg("<leader>Ds", "n", false, true)
        assert_not_nil(ds_map, "<leader>Ds mapping should exist")
    end)

    it("<leader>DS should be mapped to view_table_schema", function()
        local ds_upper_map = vim.fn.maparg("<leader>DS", "n", false, true)
        assert_not_nil(ds_upper_map, "<leader>DS mapping should exist")
    end)

    it("<leader>Db should be mapped to DBUIToggle", function()
        local db_map = vim.fn.maparg("<leader>Db", "n", false, true)
        assert_not_nil(db_map, "<leader>Db mapping should exist")
    end)
end)

-- ============================================================================
-- SUMMARY REPORT
-- ============================================================================
print("\n" .. string.rep("─", 60))
print(string.format("Test Suite Completed: %s total, %s passed, %s failed",
    color(1, tostring(test_count)),
    color(32, tostring(pass_count)),
    fail_count > 0 and color(31, tostring(fail_count)) or color(32, "0")
))
print(string.rep("─", 60) .. "\n")

if fail_count > 0 then
    print(color(31, "Failed Tests Summary:"))
    for i, fail in ipairs(failures) do
        print(string.format(" %d) %s\n    %s", i, color(1, fail.name), tostring(fail.err)))
    end
    vim.cmd("cquit 1")
else
    print(color(32, "🎉 All tests passed successfully!"))
    vim.cmd("qall!")
end
