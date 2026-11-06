local M = {}

---Save the current buffer, formatting exactly once.
---
---conform.nvim's `format_on_save` already runs from BufWritePre when
---`vim.g.autoformat_enabled` is true. In that case this helper only writes.
---When formatting is off, it formats synchronously first and then writes once,
---so the file is never formatted twice.
---@param opts? { format?: boolean }
function M.save(opts)
    opts = opts or {}

    local bufnr = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local buftype = vim.bo[bufnr].buftype

    -- Buffers with a custom write handler (oil, dadbod, ...) own their save.
    if buftype == "acwrite" then
        pcall(vim.cmd, "silent write")
        return
    end

    if buftype ~= "" then
        vim.notify("This buffer cannot be saved", vim.log.levels.WARN, { title = "Save" })
        return
    end

    if vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then
        vim.notify("Buffer is read-only", vim.log.levels.WARN, { title = "Save" })
        return
    end

    -- An unnamed buffer needs a filename first; `:write` prompts for one.
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        pcall(vim.cmd, "write")
        return
    end

    if not vim.g.autoformat_enabled and opts.format ~= false then
        local ok, conform = pcall(require, "conform")
        if ok then
            -- Best-effort: a missing formatter or a formatter error must not
            -- prevent the file from being written.
            pcall(conform.format, {
                bufnr = bufnr,
                lsp_format = "fallback",
                async = false,
                timeout_ms = 1000,
            })
        end
    end

    local ok, err = pcall(vim.cmd, "silent write")
    if not ok then
        vim.notify("Save failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Save" })
    end
end

return M
