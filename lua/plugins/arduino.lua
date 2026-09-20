-- Arduino support is provided through PlatformIO (framework = arduino).
-- The arduino-language-server and arduino-cli are no longer used as a
-- parallel backend; clangd + PlatformIO's compile_commands.json covers
-- all C/C++ diagnostics for Arduino projects.
-- This file intentionally returns an empty table.
return {}
