# 🪟 Windows Setup & Aesthetic Terminal Guide

A comprehensive, step-by-step installation, optimization, and aesthetic configuration guide for running this Neovim configuration seamlessly on **Windows 10 / 11**.

<p align="center">
  <img src="assets/screenshot.png" alt="Neovim on Windows" width="100%" />
</p>

---

## Table of Contents

- [Overview](#overview)
- [1. Prerequisites via Winget (Single Command)](#1-prerequisites-via-winget-single-command)
- [2. Nerd Font Installation](#2-nerd-font-installation)
- [3. Dedicated Python Virtual Environment](#3-dedicated-python-virtual-environment)
- [4. Clone & Bootstrap Configuration](#4-clone--bootstrap-configuration)
- [5. Windows Terminal Aesthetic Setup](#5-windows-terminal-aesthetic-setup)
- [6. Fast Launch Keyboard Shortcuts (`Ctrl+G` to open CWD)](#6-fast-launch-keyboard-shortcuts-ctrlg-to-open-cwd)
  - [Method A: Universal Windows Terminal Action (Recommended)](#method-a-universal-windows-terminal-action-recommended)
  - [Method B: PowerShell Profile Keyhandler](#method-b-powershell-profile-keyhandler)
  - [Method C: Command Prompt (CMD / Clink / Doskey)](#method-c-command-prompt-cmd--clink--doskey)
- [7. Troubleshooting & Common Windows Pitfalls](#7-troubleshooting--common-windows-pitfalls)
  - [Issue 1: PowerShell Script Execution Policy](#issue-1-powershell-script-execution-policy)
  - [Issue 2: Treesitter Compiler Missing (C/C++ Toolchain)](#issue-2-treesitter-compiler-missing-cc-toolchain)
  - [Issue 3: Node / npm Not Recognized in PATH](#issue-3-node--npm-not-recognized-in-path)
  - [Issue 4: Git Not Recognized in PATH](#issue-4-git-not-recognized-in-path)
  - [Issue 5: Symlink Permissions (Developer Mode)](#issue-5-symlink-permissions-developer-mode)
  - [Issue 6: Windows Defender Slowing Down Neovim](#issue-6-windows-defender-slowing-down-neovim)
- [8. Visual Gallery](#8-visual-gallery)

---

## Overview

Running a modern Neovim setup on Windows requires bridging system-level dependencies (compilers, terminal capabilities, font glyphs, and Python bindings). This guide ensures:
- Zero errors during Treesitter parser compilation.
- Proper diagnostic and UI icons via Nerd Fonts.
- Rich terminal graphics and transparency through Windows Terminal.
- Instant access using system-wide `Ctrl+G` keybinds.

---

## 1. Prerequisites via Winget (Single Command)

Windows Package Manager (`winget`) provides the cleanest, automated installation path.

Open **PowerShell** (or Windows Terminal) and run:

```powershell
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd tree-sitter.tree-sitter OpenJS.NodeJS.LTS Python.Python.3.12 LLVM.LLVM JesseDuffield.lazygit 7zip.7zip Microsoft.WindowsTerminal NerdFonts.JetBrainsMono -e
```

### Individual Package Breakdown:

| Tool | Winget ID | Description |
| :--- | :--- | :--- |
| **Neovim** | `Neovim.Neovim` | Neovim 0.10+ editor binary |
| **Git** | `Git.Git` | Git version control for plugin cloning & diffing |
| **ripgrep** | `BurntSushi.ripgrep.MSVC` | Blazing fast regex search for `snacks.picker` |
| **fd** | `sharkdp.fd` | Fast directory traversing for fuzzy file finders |
| **Tree-sitter CLI** | `tree-sitter.tree-sitter` | Grammar parser generator for syntax trees |
| **Node.js LTS** | `OpenJS.NodeJS.LTS` | LSP servers (`vtsls`, `pyright`, `jsonls`) & web tools |
| **Python 3.12** | `Python.Python.3.12` | Runtime for Molten, Jupyter kernels, and Python LSP |
| **LLVM / Clang** | `LLVM.LLVM` | C/C++ compiler for compiling Treesitter grammars & C code |
| **Lazygit** | `JesseDuffield.lazygit` | Floating terminal Git UI (`<leader>gl`) |
| **7-Zip** | `7zip.7zip` | Archive extraction for Mason tool installations |
| **Windows Terminal** | `Microsoft.WindowsTerminal` | GPU-accelerated modern terminal emulator |
| **JetBrains Mono Nerd Font** | `NerdFonts.JetBrainsMono` | High-fidelity patched developer font with icons |

*(Alternative package managers: `scoop install neovim git ripgrep fd tree-sitter nodejs python lazygit llvm 7zip` or `choco install neovim git ripgrep fd treesitter nodejs python lazygit llvm 7zip`)*

---

## 2. Nerd Font Installation

If not installed via winget above, install **JetBrainsMono Nerd Font** directly:

```powershell
winget install --id NerdFonts.JetBrainsMono -e
```

*Alternative options:*
- **Cascadia Code Nerd Font**: `winget install --id NerdFonts.CascadiaCode -e`
- **FiraCode Nerd Font**: `winget install --id NerdFonts.FiraCode -e`

> [!TIP]
> After installing the font, restart Windows Terminal so the new font family appears in your font selection list.

---

## 3. Dedicated Python Virtual Environment

This configuration isolates the Python provider and Jupyter/Molten data science dependencies inside `$HOME\.venvs\neovim`:

```powershell
# 1. Create the dedicated virtual environment
python -m venv "$HOME\.venvs\neovim"

# 2. Upgrade pip
& "$HOME\.venvs\neovim\Scripts\pip.exe" install --upgrade pip

# 3. Install pynvim, Jupyter, and rendering dependencies
& "$HOME\.venvs\neovim\Scripts\pip.exe" install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

---

## 4. Clone & Bootstrap Configuration

Clone this repository into the Windows Neovim configuration folder (`$env:LOCALAPPDATA\nvim`):

```powershell
# 1. Backup any existing configuration
Rename-Item -Path "$env:LOCALAPPDATA\nvim" -NewName "nvim.bak" -ErrorAction SilentlyContinue
Rename-Item -Path "$env:LOCALAPPDATA\nvim-data" -NewName "nvim-data.bak" -ErrorAction SilentlyContinue

# 2. Clone the repository
git clone https://github.com/codebyneeraj/nvim-config.git "$env:LOCALAPPDATA\nvim"

# 3. Launch Neovim
nvim
```

On first launch, `lazy.nvim` will automatically clone all plugins and Mason will install language servers. Run `:checkhealth` to verify your environment.

---

## 5. Windows Terminal Aesthetic Setup

To match the clean, frosted aesthetic shown in the screenshots, configure Windows Terminal with acrylic transparency, custom padding, and the Nerd Font.

<p align="center">
  <img src="assets/theme.png" alt="Theme & Aesthetic Visuals" width="100%" />
</p>

### `settings.json` Profile Configuration

1. Press `Ctrl + Shift + ,` inside Windows Terminal to open `settings.json`.
2. Locate the `profiles` -> `defaults` section (or your PowerShell profile) and merge the following settings:

```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "JetBrainsMono Nerd Font",
        "size": 11.5,
        "weight": "normal"
      },
      "opacity": 88,
      "useAcrylic": true,
      "padding": "12, 12, 12, 12",
      "cursorShape": "bar",
      "historySize": 9001,
      "adjustIndistinguishableColors": "always",
      "experimental.retroTerminalEffect": false
    }
  },
  "schemes": [
    {
      "name": "Frosted Dark",
      "background": "#0D1117",
      "foreground": "#E6EDF3",
      "black": "#161B22",
      "red": "#FF7B72",
      "green": "#7EE787",
      "yellow": "#FFA657",
      "blue": "#79C0FF",
      "purple": "#D2A8FF",
      "cyan": "#56D4DD",
      "white": "#F0F6FC",
      "brightBlack": "#484F58",
      "brightRed": "#FFA198",
      "brightGreen": "#56D364",
      "brightYellow": "#E3B341",
      "brightBlue": "#58A6FF",
      "brightPurple": "#BC8CFF",
      "brightCyan": "#39C5CF",
      "brightWhite": "#FFFFFF",
      "cursorColor": "#58A6FF",
      "selectionBackground": "#264F78"
    }
  ]
}
```

---

## 6. Fast Launch Keyboard Shortcuts (`Ctrl+G` to open CWD)

Quickly open Neovim in the current working directory (`nvim .`) with **`Ctrl+G`**.

### Method A: Universal Windows Terminal Action (Recommended)

This works in **any** shell running inside Windows Terminal (PowerShell, CMD, Git Bash, WSL) with zero shell scripting.

Add this action to your Windows Terminal `settings.json` under `"actions"`:

```json
"actions": [
  {
    "command": { "action": "sendInput", "input": "nvim .\r" },
    "keys": "ctrl+g"
  }
]
```

Pressing `Ctrl+G` anywhere inside Windows Terminal will immediately execute `nvim .` in the current directory!

---

### Method B: PowerShell Profile Keyhandler

If you want the shortcut native to PowerShell (even outside Windows Terminal):

1. Open your PowerShell profile in Neovim:
   ```powershell
   nvim $PROFILE
   ```
   *(If the file does not exist, create it with `New-Item -Path $PROFILE -Type File -Force`)*

2. Add the following key handler to `$PROFILE`:

```powershell
# Quick launch Neovim in CWD via Ctrl+G
Set-PSReadLineKeyHandler -Key "Ctrl+g" -BriefDescription "Launch Neovim in CWD" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('nvim .')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Optional convenience alias
Set-Alias -Name v -Value nvim
```

3. Reload your profile:
   ```powershell
   . $PROFILE
   ```

---

### Method C: Command Prompt (CMD / Clink / Doskey)

For native Windows Command Prompt (`cmd.exe`):

#### 1. Using Clink (Modern GNU Readline for CMD)
If using Clink (`winget install chrisant996.clink -e`), create `%LOCALAPPDATA%\clink\nvim_cwd.lua`:

```lua
-- Save in %LOCALAPPDATA%\clink\nvim_cwd.lua
clink.onbeginedit(function ()
    rl.setkeybinding([["\C-g"]], function ()
        rl.setline("nvim .")
        rl.invokecommand("accept-line")
    end)
end)
```

#### 2. Using DOSKEY Macro (Autorun)
Create a batch file `C:\tools\macros.cmd`:
```cmd
@echo off
doskey v=nvim .
doskey nv=nvim $*
```
Set it to load automatically in CMD:
```powershell
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "C:\tools\macros.cmd" /f
```

---

## 7. Troubleshooting & Common Windows Pitfalls

### Issue 1: PowerShell Script Execution Policy
**Symptom**: `File ... cannot be loaded because running scripts is disabled on this system.`  
**Fix**: Allow local signed scripts for the current user:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

---

### Issue 2: Treesitter Compiler Missing (C/C++ Toolchain)
**Symptom**: `treesitter: ... compiler not found` or parser compilation fails.  
**Fix**: Install LLVM/Clang or MinGW-w64 via winget:
```powershell
winget install LLVM.LLVM -e
```
Verify that `clang --version` or `gcc --version` is accessible in your path.

---

### Issue 3: Node / npm Not Recognized in PATH
**Symptom**: `node` or `npm` command not found when installing LSP servers like `vtsls` or `pyright`.  
**Fix**: Ensure Node.js and its global npm directory are in your User / System `PATH`:
- Default Node install path: `C:\Program Files\nodejs\`
- Global npm binaries: `%APPDATA%\npm`

In PowerShell, verify with:
```powershell
Get-Command node, npm
```

---

### Issue 4: Git Not Recognized in PATH
**Symptom**: `lazy.nvim` cannot clone plugins or `:ConfigUpdate` fails.  
**Fix**: Add Git's command directory to your PATH:
- `C:\Program Files\Git\cmd`
- `C:\Program Files\Git\bin`

---

### Issue 5: Symlink Permissions (Developer Mode)
**Symptom**: Neovim plugins or package managers fail when creating symbolic links.  
**Fix**: Enable Windows Developer Mode to allow unprivileged symlink creation without requiring Administrator prompts.
1. Open Windows Settings (`Win + I`).
2. Navigate to **System** -> **For developers** (or search "Developer settings").
3. Toggle **Developer Mode** to **On**.

---

### Issue 6: Windows Defender Slowing Down Neovim
**Symptom**: Sluggish startup time or high CPU usage from `Antimalware Service Executable`.  
**Fix**: Add exclusions in Windows Defender for Neovim's config and data directories:
```powershell
# Run PowerShell as Administrator:
Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\nvim"
Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\nvim-data"
Add-MpPreference -ExclusionProcess "nvim.exe"
```

---

## 8. Visual Gallery

<p align="center">
  <img src="assets/screenshot2.png" alt="Workflow & Key Features" width="100%" />
</p>

- **Multi-Modal Pickers**: `<leader>ff` (Files), `<leader>fg` (Live Grep), `<leader>fb` (Buffers) via `snacks.picker`.
- **Inline Diagnostics**: Curved diagnostic boxes via `tiny-inline-diagnostic.nvim`.
- **AI Integration**: Copilot chat & fast inline completions.
- **Dynamic Theming**: Matugen wallpaper extraction & live theme switcher (`<leader>un` / `<leader>up`).

---

[← Back to Main README](README.md)
