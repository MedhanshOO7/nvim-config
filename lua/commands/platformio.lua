-- lua/commands/platformio.lua
-- PlatformIO integration: the single embedded-development backend.
-- Neovim is the UI layer; PlatformIO (pio) is the source of truth.

local M = {}

-- ── Lazy plugin accessors ──────────────────────────────────────
-- Accessed lazily so this module can be required before plugins load.
local function toggleterm()
    return require("toggleterm")
end

local function snacks()
    return require("snacks")
end

-- ── Helpers ───────────────────────────────────────────────────

--- Run cmd in a toggleterm split.
---@param cmd string Shell command to execute
---@param opts? {direction?: string, size?: number, close_on_exit?: boolean}
local function run_in_terminal(cmd, opts)
    opts = opts or {}
    local direction = opts.direction or "horizontal"
    local size = opts.size or 15
    local close_on_exit = opts.close_on_exit or false
    toggleterm().exec(cmd, nil, size, nil, direction, nil, false, not close_on_exit)
end

--- Walk upward from cwd to find the directory containing platformio.ini.
---@return string|nil
local function get_project_root()
    local cwd = vim.fn.getcwd()
    -- Check cwd first (most common case)
    if vim.fn.filereadable(cwd .. "/platformio.ini") == 1 then
        return cwd
    end
    -- Walk upward
    local found = vim.fs.find("platformio.ini", { upward = true, path = cwd })[1]
    if found then
        return vim.fn.fnamemodify(found, ":h")
    end
    return nil
end

--- Return true when the current working directory is a PlatformIO project.
---@return boolean
function M.is_platformio_project()
    return get_project_root() ~= nil
end

local function notify_error(msg)
    vim.notify("PlatformIO: " .. msg, vim.log.levels.ERROR, { title = "PlatformIO" })
end

local function notify_info(msg)
    vim.notify("PlatformIO: " .. msg, vim.log.levels.INFO, { title = "PlatformIO" })
end

local function notify_warn(msg)
    vim.notify("PlatformIO: " .. msg, vim.log.levels.WARN, { title = "PlatformIO" })
end

--- Parse `pio device list` stdout into a list of {port, description} tables.
---@param stdout string Raw stdout from `pio device list`
---@return {port: string, description: string}[]
local function parse_devices(stdout)
    local devices = {}
    -- pio device list output (serial section) looks like:
    --   /dev/ttyUSB0
    --   ----
    --   Hardware ID: USB VID:PID=...
    --   Description: CP2102N ...
    -- We collect lines that look like /dev/tty* or COM ports.
    for line in vim.gsplit(stdout, "\n", { plain = true }) do
        local trimmed = line:match("^%s*(.-)%s*$") -- trim whitespace
        if trimmed ~= "" and (trimmed:match("^/dev/tty") or trimmed:match("^COM%d")) then
            table.insert(devices, { port = trimmed, description = trimmed })
        end
    end
    return devices
end

-- ── Project Initialization ────────────────────────────────────

--- Initialize a new PlatformIO project in the CURRENT directory.
--- Guides the user through board/framework selection using PlatformIO's own
--- board database, then calls `pio project init`.
function M.init_platformio_project()
    local root = get_project_root()
    if root then
        notify_info("PlatformIO project already exists at: " .. root)
        vim.ui.select({ "Open src/main.cpp", "Cancel" }, {
            prompt = "Project already initialized.",
        }, function(choice)
            if choice == "Open src/main.cpp" then
                local main = root .. "/src/main.cpp"
                if vim.fn.filereadable(main) == 1 then
                    vim.cmd("edit " .. vim.fn.fnameescape(main))
                else
                    notify_warn("src/main.cpp not found")
                end
            end
        end)
        return
    end

    local cwd = vim.fn.getcwd()

    -- Step 1: ask for board
    vim.ui.input({
        prompt = "PlatformIO board ID (e.g. uno, esp32dev, teensy40): ",
        default = "",
    }, function(board)
        if not board or board:match("^%s*$") then
            notify_warn("Initialization cancelled — no board provided")
            return
        end
        board = board:match("^%s*(.-)%s*$")

        -- Step 2: ask for framework (optional — pio will infer if left blank)
        vim.ui.input({
            prompt = "Framework (e.g. arduino, espidf, zephyr) [leave blank to skip]: ",
            default = "",
        }, function(framework)
            framework = framework and framework:match("^%s*(.-)%s*$") or ""

            -- Build `pio project init` command
            local cmd = string.format("pio project init --board %s", board)
            if framework ~= "" then
                cmd = cmd .. " --project-option 'framework=" .. framework .. "'"
            end
            -- Always init in CWD
            cmd = cmd .. " --project-dir " .. vim.fn.shellescape(cwd)

            notify_info(string.format("Initializing project in %s (board: %s%s)…",
                cwd, board, framework ~= "" and ", framework: " .. framework or ""))

            -- Run in a terminal so the user can see PlatformIO's output live
            run_in_terminal(cmd .. "; echo ''; echo '=== Done. Press q to close ==='", {
                direction = "horizontal",
                size = 20,
                close_on_exit = false,
            })

            -- After a delay, verify the project was created and refresh state
            vim.defer_fn(function()
                local ini = cwd .. "/platformio.ini"
                if vim.fn.filereadable(ini) == 1 then
                    notify_info("Project created. Refreshing LSP…")
                    -- Refresh clangd: generate compile_commands.json
                    vim.system({ "pio", "run", "--target", "compiledb" }, { cwd = cwd }, function(obj)
                        if obj.code ~= 0 then
                            notify_warn("compile_commands.json generation failed — clangd accuracy may be limited")
                        else
                            notify_info("compile_commands.json generated. clangd is ready.")
                            -- Trigger LspRestart so clangd picks up the new DB
                            vim.schedule(function()
                                pcall(vim.cmd, "LspRestart clangd")
                            end)
                        end
                    end)

                    -- Open src/main.cpp if it exists
                    local main = cwd .. "/src/main.cpp"
                    if vim.fn.filereadable(main) == 1 then
                        vim.schedule(function()
                            vim.cmd("edit " .. vim.fn.fnameescape(main))
                        end)
                    end
                end
            end, 5000)
        end)
    end)
end

-- ── Build ─────────────────────────────────────────────────────

function M.build_platformio()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end
    notify_info("Building…")
    run_in_terminal("cd " .. vim.fn.shellescape(root) .. " && pio run", {
        direction = "horizontal",
        size = 15,
    })
end

function M.rebuild_platformio()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end
    notify_info("Rebuilding (clean + build)…")
    run_in_terminal("cd " .. vim.fn.shellescape(root) .. " && pio run --target clean && pio run", {
        direction = "horizontal",
        size = 15,
    })
end

function M.clean_build_platformio()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end
    notify_info("Cleaning build artifacts…")
    run_in_terminal("cd " .. vim.fn.shellescape(root) .. " && pio run --target clean", {
        direction = "horizontal",
        size = 15,
    })
end

-- ── Upload ────────────────────────────────────────────────────

function M.upload_platformio()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end

    vim.system({ "pio", "device", "list" }, { text = true, cwd = root }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                notify_error("Failed to list devices: " .. (result.stderr or ""))
                return
            end

            local devices = parse_devices(result.stdout or "")

            if #devices == 0 then
                -- No devices found; let PlatformIO use its configured upload_port
                notify_info("No serial devices detected — using PlatformIO default port")
                run_in_terminal("cd " .. vim.fn.shellescape(root) .. " && pio run --target upload", {
                    direction = "horizontal",
                    size = 15,
                })
                return
            end

            if #devices == 1 then
                -- Only one device — no need for a picker
                local port = devices[1].port
                notify_info("Uploading to " .. port)
                run_in_terminal("cd " .. vim.fn.shellescape(root) .. " && pio run --target upload --upload-port " .. vim.fn.shellescape(port), {
                    direction = "horizontal",
                    size = 15,
                })
                return
            end

            snacks().picker.pick({
                title = "Select Upload Port",
                items = vim.iter(devices):map(function(d)
                    return { text = d.port .. "  " .. d.description, value = d.port }
                end):totable(),
                confirm = function(picker, item)
                    picker:close()
                    local port = item.value
                    notify_info("Uploading to " .. port)
                    run_in_terminal("cd " .. vim.fn.shellescape(root) .. " && pio run --target upload --upload-port " .. vim.fn.shellescape(port), {
                        direction = "horizontal",
                        size = 15,
                    })
                end,
            })
        end)
    end)
end

-- ── Serial Monitor ────────────────────────────────────────────

function M.serial_monitor_platformio()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end

    vim.system({ "pio", "device", "list" }, { text = true, cwd = root }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                notify_error("Failed to list devices: " .. (result.stderr or ""))
                return
            end

            local devices = parse_devices(result.stdout or "")

            local function open_monitor(port)
                vim.ui.input({
                    prompt = "Baud rate (default 115200): ",
                    default = "115200",
                }, function(baud)
                    baud = (baud and baud ~= "") and baud or "115200"
                    local cmd = "cd " .. vim.fn.shellescape(root) .. " && pio device monitor"
                    if port then
                        cmd = cmd .. " --port " .. vim.fn.shellescape(port)
                    end
                    cmd = cmd .. " --baud " .. baud
                    notify_info("Opening monitor" .. (port and " on " .. port or "") .. " @ " .. baud)
                    run_in_terminal(cmd, { direction = "vertical", size = 40 })
                end)
            end

            if #devices == 0 then
                -- Let PlatformIO pick the port automatically
                open_monitor(nil)
            elseif #devices == 1 then
                open_monitor(devices[1].port)
            else
                snacks().picker.pick({
                    title = "Select Serial Monitor Port",
                    items = vim.iter(devices):map(function(d)
                        return { text = d.port .. "  " .. d.description, value = d.port }
                    end):totable(),
                    confirm = function(picker, item)
                        picker:close()
                        open_monitor(item.value)
                    end,
                })
            end
        end)
    end)
end

-- ── Upload + Monitor ──────────────────────────────────────────

function M.upload_and_monitor_platformio()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end

    vim.system({ "pio", "device", "list" }, { text = true, cwd = root }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                notify_error("Failed to list devices: " .. (result.stderr or ""))
                return
            end

            local devices = parse_devices(result.stdout or "")

            local function do_upload_monitor(port)
                local cmd = "cd " .. vim.fn.shellescape(root) .. " && pio run --target upload"
                if port then cmd = cmd .. " --upload-port " .. vim.fn.shellescape(port) end
                cmd = cmd .. " && pio device monitor"
                if port then cmd = cmd .. " --port " .. vim.fn.shellescape(port) end
                notify_info("Uploading then monitoring" .. (port and " on " .. port or ""))
                run_in_terminal(cmd, { direction = "horizontal", size = 15 })
            end

            if #devices <= 1 then
                do_upload_monitor(devices[1] and devices[1].port or nil)
            else
                snacks().picker.pick({
                    title = "Select Port for Upload + Monitor",
                    items = vim.iter(devices):map(function(d)
                        return { text = d.port .. "  " .. d.description, value = d.port }
                    end):totable(),
                    confirm = function(picker, item)
                        picker:close()
                        do_upload_monitor(item.value)
                    end,
                })
            end
        end)
    end)
end

-- ── Device Selection ──────────────────────────────────────────

function M.select_device()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end

    vim.system({ "pio", "device", "list" }, { text = true, cwd = root }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                notify_error("Failed to list devices: " .. (result.stderr or ""))
                return
            end

            local devices = parse_devices(result.stdout or "")

            if #devices == 0 then
                notify_info("No serial devices found")
                return
            end

            snacks().picker.pick({
                title = "Connected Devices",
                items = vim.iter(devices):map(function(d)
                    return { text = d.port .. "  " .. d.description, value = d.port }
                end):totable(),
                confirm = function(picker, item)
                    picker:close()
                    notify_info("Selected: " .. item.value)
                end,
            })
        end)
    end)
end

-- ── Library Management ────────────────────────────────────────

function M.libraries_marketplace()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end

    vim.ui.select({ "Search libraries", "List installed libraries" }, {
        prompt = "PlatformIO Libraries",
    }, function(choice)
        if not choice then return end

        if choice == "List installed libraries" then
            notify_info("Fetching installed libraries…")
            vim.system({ "pio", "lib", "list", "--json-output" }, { text = true, cwd = root }, function(result)
                vim.schedule(function()
                    if result.code ~= 0 then
                        notify_error("Failed to list libraries: " .. (result.stderr or ""))
                        return
                    end
                    local ok, libs = pcall(vim.json.decode, result.stdout or "")
                    if not ok or type(libs) ~= "table" then
                        notify_error("Failed to parse library list")
                        return
                    end
                    if #libs == 0 then
                        notify_info("No libraries installed in this project")
                        return
                    end
                    snacks().picker.pick({
                        title = "Installed PlatformIO Libraries",
                        items = vim.iter(libs):map(function(lib)
                            return {
                                text = (lib.name or "?") .. " v" .. (lib.version or "?"),
                                description = (lib.description or ""),
                                value = tostring(lib.id or lib.name or ""),
                            }
                        end):totable(),
                        confirm = function(picker, _)
                            picker:close()
                        end,
                    })
                end)
            end)
        else
            -- Search
            vim.ui.input({ prompt = "Search PlatformIO libraries: " }, function(query)
                if not query or query:match("^%s*$") then return end
                query = query:match("^%s*(.-)%s*$")
                notify_info("Searching for: " .. query)
                vim.system({ "pio", "lib", "search", query, "--json-output" }, { text = true }, function(result)
                    vim.schedule(function()
                        if result.code ~= 0 then
                            notify_error("Library search failed: " .. (result.stderr or ""))
                            return
                        end
                        local ok, data = pcall(vim.json.decode, result.stdout or "")
                        -- pio lib search JSON wraps results in {"items": [...]}
                        local libs = (ok and type(data) == "table" and (data.items or data)) or {}
                        if type(libs) ~= "table" or #libs == 0 then
                            notify_info("No libraries found for: " .. query)
                            return
                        end
                        snacks().picker.pick({
                            title = "PlatformIO Libraries — " .. query,
                            items = vim.iter(libs):map(function(lib)
                                return {
                                    text = (lib.name or "?") .. " v" .. (lib.version or "?") .. " by " .. (lib.authornames and lib.authornames[1] or "?"),
                                    description = lib.description or "",
                                    value = tostring(lib.id or lib.name or ""),
                                }
                            end):totable(),
                            confirm = function(picker, item)
                                picker:close()
                                local lib_id = item.value
                                notify_info("Installing " .. lib_id .. "…")
                                vim.system({ "pio", "lib", "install", lib_id }, { text = true, cwd = root }, function(install_result)
                                    vim.schedule(function()
                                        if install_result.code ~= 0 then
                                            notify_error("Installation failed: " .. (install_result.stderr or ""))
                                        else
                                            notify_info("Installed: " .. lib_id)
                                        end
                                    end)
                                end)
                            end,
                        })
                    end)
                end)
            end)
        end
    end)
end

-- ── clangd / compile_commands.json ───────────────────────────

--- Generate (or regenerate) compile_commands.json via PlatformIO and restart clangd.
function M.refresh_clangd()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end
    notify_info("Generating compile_commands.json…")
    vim.system({ "pio", "run", "--target", "compiledb" }, { text = true, cwd = root }, function(obj)
        vim.schedule(function()
            if obj.code ~= 0 then
                notify_error("compile_commands.json generation failed:\n" .. (obj.stderr or ""))
            else
                notify_info("compile_commands.json ready — restarting clangd")
                pcall(vim.cmd, "LspRestart clangd")
            end
        end)
    end)
end

-- ── Project Status ────────────────────────────────────────────

--- Show current project info (board, platform, framework) from PlatformIO.
function M.project_info()
    local root = get_project_root()
    if not root then
        notify_error("No PlatformIO project found (missing platformio.ini)")
        return
    end

    -- Read platformio.ini and show it in a floating buffer
    local ini = root .. "/platformio.ini"
    if vim.fn.filereadable(ini) == 0 then
        notify_error("platformio.ini not found in " .. root)
        return
    end

    local lines = vim.fn.readfile(ini)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = "ini"
    vim.bo[buf].modifiable = false

    local width = math.min(70, vim.o.columns - 4)
    local height = math.min(#lines + 2, vim.o.lines - 4)
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " platformio.ini ",
        title_pos = "center",
    })
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

return M
