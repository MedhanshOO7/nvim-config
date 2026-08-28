local M = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Report Tool" })
end

function M.build(opts)
    opts = opts or {}
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or not (vim.endswith(file, ".md") or vim.endswith(file, ".markdown")) then
        notify("Current buffer is not a markdown file.", vim.log.levels.WARN)
        return
    end

    -- Save file before building
    if vim.bo.modified then
        vim.cmd("silent write")
    end

    local cmd = { "report-tool", file }
    if opts.pdf then
        table.insert(cmd, "--pdf")
    end

    notify("Building report for " .. vim.fn.fnamemodify(file, ":t") .. "...", vim.log.levels.INFO)

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        print(line)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                local err_msg = table.concat(data, "\n")
                if err_msg:match("%S") then
                    notify("Build output:\n" .. err_msg, vim.log.levels.WARN)
                end
            end
        end,
        on_exit = function(_, code)
            if code == 0 then
                notify("Report generated successfully!", vim.log.levels.INFO)
                if opts.open_pdf then
                    local pdf_file = vim.fn.fnamemodify(file, ":r") .. ".pdf"
                    if vim.fn.filereadable(pdf_file) == 1 then
                        vim.fn.jobstart({ "xdg-open", pdf_file }, { detach = true })
                    end
                end
            else
                notify("Report build failed with exit code " .. code, vim.log.levels.ERROR)
            end
        end,
    })
end

function M.init_template()
    vim.ui.input({ prompt = "Report subject (e.g. dsa, dbms, web): ", default = "dsa" }, function(subject)
        if not subject or subject == "" then return end
        vim.ui.input({ prompt = "Practical title / aim: " }, function(title)
            vim.ui.input({ prompt = "Output filename (optional, e.g. lab1.md): " }, function(filename)
                local cmd = { "report-tool", "init", "--subject", subject }
                if title and title ~= "" then
                    table.insert(cmd, "--title")
                    table.insert(cmd, title)
                end
                if filename and filename ~= "" then
                    table.insert(cmd, filename)
                end

                local out = vim.fn.system(cmd)
                if vim.v.shell_error == 0 then
                    notify(out:gsub("\n", " "), vim.log.levels.INFO)
                    local created = out:match("Created template: (%S+)")
                    if created and vim.fn.filereadable(created) == 1 then
                        vim.cmd("edit " .. vim.fn.fnameescape(created))
                    end
                else
                    notify("Failed to scaffold template: " .. out, vim.log.levels.ERROR)
                end
            end)
        end)
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("ReportBuild", function()
        M.build({ pdf = true })
    end, { desc = "Build practical report from current markdown file" })

    vim.api.nvim_create_user_command("ReportPreview", function()
        M.build({ pdf = true, open_pdf = true })
    end, { desc = "Build practical report and open PDF preview" })

    vim.api.nvim_create_user_command("ReportInit", function()
        M.init_template()
    end, { desc = "Scaffold a new practical report template" })
end

return M
