local M = {}

--- Run neotest tests with completion notification.
-- Polls neotest.state.status_counts() until all running tests finish,
-- then notifies with pass/fail/skipped summary.
---@param args? table Arguments passed to require("neotest").run.run()
function M.run_with_notify(args)
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("neotest not available", vim.log.levels.ERROR, { title = "Neotest" })
    return
  end

  local state_ok, state = pcall(require, "neotest.state")
  if not state_ok then
    vim.notify("neotest.state not available", vim.log.levels.ERROR, { title = "Neotest" })
    return
  end

  neotest.run.run(args or {})
  vim.notify("Tests running...", vim.log.levels.INFO, { title = "Neotest" })

  local attempts = 0
  local max_attempts = 60 -- 30 seconds at 500ms

  local function check()
    attempts = attempts + 1
    local adapter_ids = state.adapter_ids()
    local all_done = true
    local total, passed, failed, skipped = 0, 0, 0, 0

    for _, aid in ipairs(adapter_ids) do
      local counts = state.status_counts(aid)
      if counts then
        if counts.running and counts.running > 0 then
          all_done = false
        end
        total = total + (counts.total or 0)
        passed = passed + (counts.passed or 0)
        failed = failed + (counts.failed or 0)
        skipped = skipped + (counts.skipped or 0)
      end
    end

    if all_done and total > 0 then
      local msg = string.format("Tests: %d passed, %d failed", passed, failed)
      if skipped > 0 then
        msg = msg .. ", " .. skipped .. " skipped"
      end
      vim.notify(msg, failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO, { title = "Neotest" })
    elseif attempts < max_attempts then
      vim.defer_fn(check, 500)
    else
      vim.notify("Tests: check :Neotest summary for results", vim.log.levels.WARN, { title = "Neotest" })
    end
  end

  vim.defer_fn(check, 1000)
end

return M
