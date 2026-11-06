# Plan: Route command output to notifications (phase 1)

## Goal
Make command output reliably reach the user via notifications instead of being dropped or diverted to a split. Fix the three loss points in noice.nvim's routing.

## Affected files
- `lua/plugins/noice.lua` — the only file needing changes in phase 1.

## Current behavior (the three loss points)
1. `noice.lua:293-295` — route skips every `msg_show` containing "written" → `:w` produces zero feedback.
2. `noice.lua:362-368` — route sends any `msg_show` with `min_height >= 15` to a `split` view → medium command output never becomes a notification.
3. `noice.lua:133-136` — `notify = { enabled = false }` → `vim.notify()` echoes and rides the lossy `echo → msg_show → messages` chain, subject to rules 1 & 2; error/warn timeout routes (`event = "notify"`) never apply.

## Decisions (phase 1)
1. **Remove only `{ find = "written" }` from the `msg_show` skip route** (`noice.lua:293-295`), keeping the DSR/E1568/deprecation skips intact. Deleting the whole block (lines 272-302) would re-enable terminal DSR warnings and LSP deprecation notices as notifications — a regression. With `written` removed from the skip, `:w` echo reaches `messages.view = "notify"` and appears as a notification + in `:Noice` history.
   - Auto-save (`auto-save.nvim`, debounced 1.5s on `TextChanged`) will also produce save notifications if it emits a "written" msg_show. This is debounced and dismissible with `<leader>nd`; no separate `BufWritePost` autocmd is added to avoid double-notify. If noise is unacceptable, the user toggles auto-save off with `<leader>ua`.

2. **Re-enable `vim.notify` interception**: set `notify = { enabled = true, view = "notify" }` (`noice.lua:133-136`) so `vim.notify()` goes straight to noice's notify view, bypassing the echo→msg_show chain. Error/warn timeout routes (`noice.lua:325-349`) then apply to `vim.notify()` calls. No double-show: when enabled, noice intercepts `vim.notify()` and does not also emit a `msg_show`.

3. **Raise long-output split threshold** from `min_height = 15` to `min_height = 30` (`noice.lua:364`). Output of 15–29 lines renders as a notification; 30+ lines still falls back to a split (a 200-line build log as a notification is unusable). Never silently drops output.

## Out of scope (phase 2 — not implementation-ready now)
- **code-runner completion notification** (`code-runner.lua`, `terminal.lua`): persistent toggleterm has no completion callback. Needs a `vim.fn.jobstart` wrapper or migration to overseer tasks (overseer already supports `on_complete_notify`).
- **neotest completion notification** (`elite-extra.lua`): no clean public "run finished" callback; `output = { open_on_run = true }` already opens results.
- **LSP server start/failure** (`lua/plugins/lsp.lua`), **PlatformIO upload-completion** (`lua/commands/platformio.lua`), **format-on-save confirmation** (`core/keymaps.lua` `<leader>cf`), **desktop/system notifications** beyond nvim-notify.

## Validation steps
- `:w` a file → one notification appears (not dropped); appears in `:Noice` history.
- DSR warning / E1568 / "is_stopped is deprecated" / "client.request is deprecated" → still skipped (no regression).
- Command output of 10–25 lines → notification shows, no split forced.
- Command output of 40+ lines → split fallback still available.
- `vim.notify("hello")` → appears as a noice notification and in `:Noice` history (not just echo).
- `<leader>nd` dismisses notifications; `<leader>nh` opens `:Noice` history.
- Auto-save → notification fires (debounced; dismissible). No duplicate from a separate autocmd.

## Risks
- Re-enabling `notify` increases `vim.notify()` visibility (desired); volume is unchanged for `echo`-based messages.
- Removing `written` from `msg_show` skip may notify auto-saves too (debounced, low volume). Mitigation: `<leader>ua` disables auto-save.
- Threshold 30 shows more output as notifications; acceptable per goal. Large output still splits.

## Open questions (none blocking phase 1)
None. Code-runner and neotest completion notifications are explicitly deferred to phase 2.
