local M = {}

--- Resolve the run command for the current filetype, mirroring
-- code_runner.nvim's filetype config.
---@return string|nil command
local function get_filetype_command()
  local ft = vim.bo.filetype
  local is_win = vim.fn.has("win32") == 1
  local path = vim.fn.expand("%:p")
  local file_dir = vim.fn.expand("%:p:h")
  local file_name = vim.fn.expand("%:t")
  local file_name_without_ext = vim.fn.expand("%:t:r")

  local shellescape = vim.fn.shellescape

  local filetype_cmds = {
    python = function()
      local py_bin = is_win and "python" or "python3"
      local venv_bin = is_win and "Scripts/python.exe" or "bin/python"
      local venv = vim.env.VIRTUAL_ENV
      if not venv or venv == "" then
        local found = vim.fs.find({ ".venv", "venv" }, { upward = true, path = file_dir })[1]
        if found then
          venv = vim.fn.fnamemodify(found, ":p"):gsub("[/\\]$", "")
        end
      end
      if venv and vim.fn.executable(venv .. "/" .. venv_bin) == 1 then
        py_bin = venv .. "/" .. venv_bin
      end
      return string.format("%s -u %s", shellescape(py_bin), shellescape(path))
    end,
    typescript = "deno run --allow-all " .. shellescape(path),
    javascript = "node " .. shellescape(path),
    rust = is_win
        and string.format("cd %s && rustc %s && %s\\%s.exe", shellescape(file_dir), shellescape(file_name), shellescape(file_dir), shellescape(file_name_without_ext))
      or string.format("cd %s && rustc %s && %s/%s", shellescape(file_dir), shellescape(file_name), shellescape(file_dir), shellescape(file_name_without_ext)),
    c = is_win
        and string.format("cd %s && gcc %s -o %s\\%s.exe && %s\\%s.exe", shellescape(file_dir), shellescape(file_name), shellescape(file_dir), shellescape(file_name_without_ext), shellescape(file_dir), shellescape(file_name_without_ext))
      or string.format("cd %s && gcc %s -o /tmp/%s && /tmp/%s", shellescape(file_dir), shellescape(file_name), shellescape(file_name_without_ext), shellescape(file_name_without_ext)),
    cpp = is_win
        and string.format("cd %s && g++ -std=c++20 %s -o %s\\%s.exe && %s\\%s.exe", shellescape(file_dir), shellescape(file_name), shellescape(file_dir), shellescape(file_name_without_ext), shellescape(file_dir), shellescape(file_name_without_ext))
      or string.format("cd %s && g++ -std=c++20 %s -o /tmp/%s && /tmp/%s", shellescape(file_dir), shellescape(file_name), shellescape(file_name_without_ext), shellescape(file_name_without_ext)),
    sh = "bash " .. shellescape(path),
    zsh = "zsh " .. shellescape(path),
    ps1 = "powershell -ExecutionPolicy Bypass -File " .. shellescape(path),
    bat = "cmd /c " .. shellescape(path),
    cmd = "cmd /c " .. shellescape(path),
    lua = "nvim -l " .. shellescape(path),
    go = "go run " .. shellescape(path),
    markdown = "report-tool " .. shellescape(path),
  }

  local cmd = filetype_cmds[ft]
  if type(cmd) == "function" then
    return cmd()
  end
  return cmd
end

--- Run a command via jobstart with live output and completion notification.
---@param cmd string The shell command to execute
---@param cwd string Working directory
---@param label string Notification title
function M.run_with_notify(cmd, cwd, label)
  label = label or "Code Runner"
  cwd = cwd or vim.fn.expand("%:p:h")

  vim.notify("Running: " .. cmd, vim.log.levels.INFO, { title = label })

  local output_lines = {}

  vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
            vim.schedule(function()
              print(line)
            end)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
            vim.schedule(function()
              vim.notify(line, vim.log.levels.WARN, { title = label })
            end)
          end
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("Run OK", vim.log.levels.INFO, { title = label })
        else
          local tail = table.concat(output_lines, "\n")
          if #tail > 0 then
            tail = tail:sub(-200)
          end
          vim.notify(
            "Run failed (exit " .. code .. ")" .. (#tail > 0 and "\n" .. tail or ""),
            vim.log.levels.ERROR,
            { title = label }
          )
        end
      end)
    end,
  })
end

--- Run the current file with completion notification.
function M.run_current_file()
  local cmd = get_filetype_command()
  if not cmd then
    vim.notify("No run command configured for filetype: " .. vim.bo.filetype, vim.log.levels.WARN, { title = "Code Runner" })
    return
  end
  vim.cmd("silent write")
  M.run_with_notify(cmd, vim.fn.expand("%:p:h"), "Code Runner")
end

return M
