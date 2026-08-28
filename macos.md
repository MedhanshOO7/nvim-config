# 🍎 macOS Setup & Aesthetic Terminal Guide

A comprehensive, step-by-step installation, optimization, and aesthetic configuration guide for running this Neovim configuration seamlessly on **macOS (Apple Silicon M1/M2/M3/M4 & Intel)**.

<p align="center">
  <img src="assets/screenshot.png" alt="Neovim on macOS" width="100%" />
</p>

---

## Table of Contents

- [Overview](#overview)
- [1. Prerequisites via Homebrew (Single Command)](#1-prerequisites-via-homebrew-single-command)
- [2. Xcode Command Line Tools](#2-xcode-command-line-tools)
- [3. Apple Silicon vs. Intel Architecture Nuances](#3-apple-silicon-vs-intel-architecture-nuances)
- [4. Nerd Font Installation](#4-nerd-font-installation)
- [5. Dedicated Python Virtual Environment](#5-dedicated-python-virtual-environment)
- [6. Clone & Bootstrap Configuration](#6-clone--bootstrap-configuration)
- [7. macOS Aesthetic Terminal Setup](#7-macos-aesthetic-terminal-setup)
  - [Option A: Ghostty (Modern Native macOS Terminal)](#option-a-ghostty-modern-native-macos-terminal)
  - [Option B: Kitty (High-Performance GPU Terminal)](#option-b-kitty-high-performance-gpu-terminal)
  - [Option C: WezTerm (Lua-Configured GPU Terminal)](#option-c-wezterm-lua-configured-gpu-terminal)
  - [Option D: iTerm2 (Classic Powerhouse)](#option-d-iterm2-classic-powerhouse)
- [8. Fast Launch Keyboard Shortcuts (`Ctrl+G` to open CWD)](#8-fast-launch-keyboard-shortcuts-ctrlg-to-open-cwd)
  - [Method A: Zsh Profile Keyhandler (macOS Default Shell)](#method-a-zsh-profile-keyhandler-macos-default-shell)
  - [Method B: Fish Shell Keyhandler](#method-b-fish-shell-keyhandler)
  - [Method C: macOS Finder Quick Action ("Open in Neovim")](#method-c-macos-finder-quick-action-open-in-neovim)
  - [Method D: Raycast / Alfred Custom Script Command](#method-d-raycast--alfred-custom-script-command)
- [9. Troubleshooting & Common macOS Pitfalls](#9-troubleshooting--common-macos-pitfalls)
  - [Issue 1: Option / Alt Key Typing Special Symbols (Meta Keybinds)](#issue-1-option--alt-key-typing-special-symbols-meta-keybinds)
  - [Issue 2: Homebrew PATH Missing in GUI Launchers (Neovide / Raycast / Spotlight)](#issue-2-homebrew-path-missing-in-gui-launchers-neovide--raycast--spotlight)
  - [Issue 3: Xcode Command Line Tools Missing or Incomplete](#issue-3-xcode-command-line-tools-missing-or-incomplete)
  - [Issue 4: Python `externally-managed-environment` (PEP 668)](#issue-4-python-externally-managed-environment-pep-668)
  - [Issue 5: Terminal Full Disk Access Permissions](#issue-5-terminal-full-disk-access-permissions)
  - [Issue 6: Terminal Image Rendering (Kitty Graphics Protocol)](#issue-6-terminal-image-rendering-kitty-graphics-protocol)
- [10. Visual Gallery](#10-visual-gallery)

---

## Overview

Running a modern, high-performance Neovim setup on macOS requires proper toolchain integration, Homebrew path discovery, font rendering, and terminal configuration. This guide ensures:
- Full Apple Silicon (`arm64`) and Intel (`x86_64`) native execution with zero emulation overhead.
- Flawless compilation of Treesitter C/C++ grammars using Apple Clang.
- Crisp icons and UI glyphs via Homebrew Cask Nerd Fonts.
- Rich in-terminal image rendering with Ghostty, Kitty, or WezTerm.
- Seamless clipboard integration with native macOS `pbcopy` and `pbpaste`.
- Instant access using system-wide `Ctrl+G` or Finder context menus.

---

## 1. Prerequisites via Homebrew (Single Command)

[Homebrew](https://brew.sh) is the standard package manager for macOS.

Open **Terminal** (or Ghostty / Kitty / iTerm2) and install all required system packages:

```bash
brew install neovim git ripgrep fd tree-sitter node python@3.12 lazygit imagemagick make shfmt stylua
brew install --cask font-jetbrains-mono-nerd-font
```

### Individual Package Breakdown:

| Tool | Homebrew Formula | Description |
| :--- | :--- | :--- |
| **Neovim** | `neovim` | Neovim 0.10+ editor binary |
| **Git** | `git` | Git version control for plugin cloning, diffing & updater |
| **ripgrep** | `ripgrep` | Blazing fast regex search for `snacks.picker` (`<leader>fg`) |
| **fd** | `fd` | Fast directory traversal for fuzzy file finders (`<leader>ff`) |
| **Tree-sitter CLI** | `tree-sitter` | Grammar parser generator for syntax trees & code highlighting |
| **Node.js** | `node` | LSP servers (`vtsls`, `pyright`, `jsonls`) & web tools |
| **Python 3.12** | `python@3.12` | Runtime for Molten, Jupyter kernels, and Python LSP |
| **Lazygit** | `lazygit` | Floating terminal Git UI (`<leader>gl`) |
| **ImageMagick** | `imagemagick` | In-terminal image rendering & preview thumbnails |
| **GNU Make** | `make` | Native C extension builds (CopilotChat tiktoken module) |
| **shfmt** | `shfmt` | Shell script formatter (`bash`, `zsh`, `sh`) |
| **StyLua** | `stylua` | Opinionated Lua code formatter for Neovim config |
| **JetBrains Mono Nerd Font** | `font-jetbrains-mono-nerd-font` (cask) | Patched developer font with UI icons & symbols |

---

## 2. Xcode Command Line Tools

Treesitter parser compilation, C/C++ development, and native plugin builds require Apple's compiler toolchain (`clang`, `make`, `ld`).

Run the following command in your terminal:

```bash
xcode-select --install
```

If a dialog appears, click **Install** and wait for the download to finish. If already installed, it will print: `xcode-select: error: command line tools are already installed`.

Verify your compiler:

```bash
clang --version
```

---

## 3. Apple Silicon vs. Intel Architecture Nuances

macOS uses different Homebrew installation prefixes depending on your Mac's CPU architecture:

| Architecture | CPU | Homebrew Prefix | Binary Directory |
| :--- | :--- | :--- | :--- |
| **Apple Silicon** | M1 / M2 / M3 / M4 / Pro / Max / Ultra | `/opt/homebrew` | `/opt/homebrew/bin` |
| **Intel** | Core i5 / i7 / i9 / Xeon | `/usr/local` | `/usr/local/bin` |

> [!NOTE]
> This Neovim configuration **automatically detects and injects** `/opt/homebrew/bin`, `/opt/homebrew/sbin`, `/usr/local/bin`, and `~/.cargo/bin` into Neovim's internal environment PATH during initialization (`init.lua`). You don't need to manually configure PATH inside Neovim!

To ensure your terminal shell also has Homebrew loaded, add this to `~/.zprofile` (or `~/.zshrc`):

```bash
# Evaluate Homebrew shell environment automatically
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

---

## 4. Nerd Font Installation

If not installed via the single Homebrew command above, install **JetBrainsMono Nerd Font** directly:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

*Alternative aesthetic Nerd Font options:*
- **FiraCode Nerd Font**: `brew install --cask font-fira-code-nerd-font`
- **Hack Nerd Font**: `brew install --cask font-hack-nerd-font`
- **Cascadia Code Nerd Font**: `brew install --cask font-caskaydia-cove-nerd-font`

> [!TIP]
> After installing the font, restart your terminal emulator so the new font appears in its font selection list.

---

## 5. Dedicated Python Virtual Environment

This configuration isolates the Python provider and Jupyter/Molten data science dependencies inside `~/.venvs/neovim`:

```bash
# 1. Create the dedicated virtual environment
python3 -m venv ~/.venvs/neovim

# 2. Upgrade pip
~/.venvs/neovim/bin/pip install --upgrade pip

# 3. Install pynvim, Jupyter, and rendering dependencies
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

---

## 6. Clone & Bootstrap Configuration

Clone this repository into the macOS Neovim configuration folder (`~/.config/nvim`):

```bash
# 1. Backup any existing configuration
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null

# 2. Clone the repository
git clone https://github.com/codebyneeraj/nvim-config.git ~/.config/nvim

# 3. Launch Neovim
nvim
```

On first launch, `lazy.nvim` will automatically clone all plugins and Mason will install language servers. Run `:checkhealth health` to verify your environment.

---

## 7. macOS Aesthetic Terminal Setup

To match the clean, frosted aesthetic with native macOS window effects, typography, and transparency, configure your preferred terminal emulator below:

<p align="center">
  <img src="assets/theme.png" alt="Theme & Aesthetic Visuals" width="100%" />
</p>

### Option A: Ghostty (Modern Native macOS Terminal)

[Ghostty](https://ghostty.org) is a fast, GPU-accelerated terminal with first-class macOS integration, native tabs, and native blur.

Create or edit `~/.config/ghostty/config` (or `~/Library/Application Support/com.mitchellh.ghostty/config`):

```ini
# Typography
font-family = "JetBrainsMono Nerd Font"
font-size = 14
font-feature = ["+calt", "+liga", "+dlig"]
adjust-cell-height = 15%

# macOS Window Appearance
window-padding-x = 16
window-padding-y = 16
window-padding-balance = true
window-theme = dark
background-opacity = 0.90
background-blur-radius = 24
macos-titlebar-style = transparent
macos-option-as-alt = true

# Mouse & Cursor
cursor-style = bar
cursor-style-blink = false
mouse-hide-while-typing = true

# Theme Colors (Frosted Dark)
background = #0D1117
foreground = #E6EDF3
palette = 0=#161B22
palette = 1=#FF7B72
palette = 2=#7EE787
palette = 3=#FFA657
palette = 4=#79C0FF
palette = 5=#D2A8FF
palette = 6=#56D4DD
palette = 7=#F0F6FC
palette = 8=#484F58
palette = 9=#FFA198
palette = 10=#56D364
palette = 11=#E3B341
palette = 12=#58A6FF
palette = 13=#BC8CFF
palette = 14=#39C5CF
palette = 15=#FFFFFF
```

---

### Option B: Kitty (High-Performance GPU Terminal)

[Kitty](https://sw.kovidgoyal.net/kitty/) offers native Kitty Graphics Protocol support for floating in-terminal image rendering (`snacks.image` and `molten-nvim`).

Create or edit `~/.config/kitty/kitty.conf`:

```conf
# Font Configuration
font_family      JetBrainsMono Nerd Font
bold_font        JetBrainsMono Nerd Font Bold
italic_font      JetBrainsMono Nerd Font Italic
bold_italic_font JetBrainsMono Nerd Font Bold Italic
font_size        14.0
disable_ligatures never

# macOS Window Styling
hide_window_decorations titlebar-only
macos_titlebar_color background
macos_option_as_alt yes
macos_quit_when_last_window_closed yes
window_padding_width 14

# Background Blur & Transparency
background_opacity 0.90
background_blur 32

# Cursor
cursor_shape beam
cursor_blink_interval 0

# Colorscheme (Frosted Dark)
background #0D1117
foreground #E6EDF3
selection_background #264F78
selection_foreground #FFFFFF

color0 #161B22
color1 #FF7B72
color2 #7EE787
color3 #FFA657
color4 #79C0FF
color5 #D2A8FF
color6 #56D4DD
color7 #F0F6FC

color8 #484F58
color9 #FFA198
color10 #56D364
color11 #E3B341
color12 #58A6FF
color13 #BC8CFF
color14 #39C5CF
color15 #FFFFFF
```

---

### Option C: WezTerm (Lua-Configured GPU Terminal)

Create or edit `~/.config/wezterm/wezterm.lua`:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14.0

-- macOS Native Vibrancy & Blur
config.window_background_opacity = 0.90
config.macos_window_background_blur = 30
config.window_decorations = "RESIZE"
config.window_padding = {
    left = 16,
    right = 16,
    top = 16,
    bottom = 16,
}

-- Send Option key as Meta / Alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.colors = {
    background = "#0D1117",
    foreground = "#E6EDF3",
    cursor_bg = "#58A6FF",
    cursor_fg = "#0D1117",
    selection_bg = "#264F78",
    ansi = {
        "#161B22", "#FF7B72", "#7EE787", "#FFA657",
        "#79C0FF", "#D2A8FF", "#56D4DD", "#F0F6FC",
    },
    brights = {
        "#484F58", "#FFA198", "#56D364", "#E3B341",
        "#58A6FF", "#BC8CFF", "#39C5CF", "#FFFFFF",
    },
}

return config
```

---

### Option D: iTerm2 (Classic Powerhouse)

1. Open **iTerm2** -> **Settings** (`Cmd + ,`).
2. Navigate to **Profiles** -> **Text**:
   - Set Font to **JetBrainsMono Nerd Font**, Size: `14`.
3. Navigate to **Profiles** -> **Window**:
   - Set **Transparency**: `10%` to `15%`.
   - Enable **Blur**: `25`.
   - Style: **No Title Bar** (or Minimal).
4. Navigate to **Profiles** -> **Keys** -> **General**:
   - Set **Left Option Key** to: **Esc+** (allows `<M-...>` shortcuts in Neovim).
   - Set **Right Option Key** to: **Esc+**.

---

## 8. Fast Launch Keyboard Shortcuts (`Ctrl+G` to open CWD)

Quickly open Neovim in the current working directory (`nvim .`) with **`Ctrl+G`**.

### Method A: Zsh Profile Keyhandler (macOS Default Shell)

Add this widget to your `~/.zshrc`:

```zsh
# Fast launch Neovim in CWD via Ctrl+G
nvim-cwd-widget() {
    BUFFER="nvim ."
    zle accept-line
}
zle -N nvim-cwd-widget
bindkey '^G' nvim-cwd-widget

# Optional convenience alias
alias v="nvim"
alias nv="nvim"
```

Reload your zsh configuration:

```bash
source ~/.zshrc
```

Now press `Ctrl+G` in any zsh terminal session to immediately launch `nvim .` in the current folder!

---

### Method B: Fish Shell Keyhandler

If using Fish shell (`~/.config/fish/config.fish`):

```fish
# Fast launch Neovim in CWD via Ctrl+G
function nvim_cwd
    commandline -r "nvim ."
    commandline -f execute
end
bind \cg nvim_cwd

alias v="nvim"
alias nv="nvim"
```

---

### Method C: macOS Finder Quick Action ("Open in Neovim")

To open any folder in Neovim directly from macOS Finder:

1. Open **Automator.app** on your Mac.
2. Select **New Document** -> **Quick Action**.
3. Set **Workflow receives current**: `files or folders` in `Finder.app`.
4. Drag the **Run AppleScript** action into the workflow and paste:

```applescript
on run {input, parameters}
    tell application "Ghostty" -- or "Kitty", "iTerm", "Terminal"
        activate
        tell application "System Events"
            keystroke "cd " & quoted form of (POSIX path of (first item of input as alias)) & " && nvim ."
            key code 36
        end tell
    end tell
end run
```

5. Save the action as **"Open in Neovim"**.
6. Now right-click any folder in Finder -> **Quick Actions** -> **Open in Neovim**!

---

### Method D: Raycast / Alfred Custom Script Command

For **Raycast** users:
1. Open Raycast -> Search **"Create Script Command"**.
2. Title: `Open Neovim in Active Finder Window`.
3. Script:
```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Open Neovim in Active Folder
# @raycast.mode silent

DIR=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
DIR=${DIR:-$HOME}
open -a Ghostty "$DIR" --args -e nvim "$DIR"
```

---

## 9. Troubleshooting & Common macOS Pitfalls

### Issue 1: Option / Alt Key Typing Special Symbols (Meta Keybinds)
**Symptom**: Pressing `<M-p>`, `<M-n>`, `<M-w>`, or `<A-h>` types special characters like `π`, `˜`, `∑`, `˙` instead of triggering Neovim shortcuts.  
**Fix**: Configure your terminal to treat Option as Meta / Alt:
- **Ghostty**: Add `macos-option-as-alt = true` to `~/.config/ghostty/config`.
- **Kitty**: Add `macos_option_as_alt yes` to `~/.config/kitty/kitty.conf`.
- **WezTerm**: Add `config.send_composed_key_when_left_alt_is_pressed = false` to `wezterm.lua`.
- **iTerm2**: Set **Left/Right Option Key** to **Esc+** in *Profiles -> Keys*.
- **Terminal.app**: Enable **"Use Option as Meta Key"** in *Settings -> Profiles -> Keyboard*.

---

### Issue 2: Homebrew PATH Missing in GUI Launchers (Neovide / Raycast / Spotlight)
**Symptom**: Neovim opened from GUI launcher gives errors like `node is not executable` or `git command not found`.  
**Fix**: This repository's `init.lua` automatically checks and injects `/opt/homebrew/bin` and `/usr/local/bin`. Additionally, ensure Homebrew is initialized in `~/.zprofile`:
```zsh
# Add to ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
```

---

### Issue 3: Xcode Command Line Tools Missing or Incomplete
**Symptom**: Treesitter parser compilation fails with `clang: error: unable to find utility "clang"`.  
**Fix**: Reset and reinstall Xcode Command Line Tools:
```bash
sudo xcode-select --reset
xcode-select --install
```

---

### Issue 4: Python `externally-managed-environment` (PEP 668)
**Symptom**: Running `pip install pynvim` produces `error: externally-managed-environment`.  
**Fix**: Do not install packages directly with global Homebrew python. Use the isolated virtual environment in step 5:
```bash
python3 -m venv ~/.venvs/neovim
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

---

### Issue 5: Terminal Full Disk Access Permissions
**Symptom**: Neovim cannot access files in `~/Desktop`, `~/Documents`, `~/Downloads`, or external drives.  
**Fix**:
1. Open **System Settings** -> **Privacy & Security** -> **Full Disk Access**.
2. Click **+** and add your terminal application (**Ghostty**, **Kitty**, **WezTerm**, or **Terminal**).
3. Toggle permission to **On** and restart the terminal.

---

### Issue 6: Terminal Image Rendering (Kitty Graphics Protocol)
**Symptom**: `<leader>ih` (Image Hover) or Molten inline plots show ASCII fallbacks instead of images.  
**Fix**: Ensure you are using a terminal emulator with Kitty Graphics Protocol support:
- **Ghostty** (native support)
- **Kitty** (native support)
- **WezTerm** (native support)
- Verify `magick` is installed: `brew install imagemagick`

---

## 10. Visual Gallery

<p align="center">
  <img src="assets/screenshot2.png" alt="Workflow & Key Features" width="100%" />
</p>

- **Multi-Modal Pickers**: `<leader>ff` (Files), `<leader>fg` (Live Grep), `<leader>fb` (Buffers) via `snacks.picker`.
- **Inline Diagnostics**: Curved diagnostic boxes via `tiny-inline-diagnostic.nvim`.
- **AI Integration**: Copilot chat & fast inline completions.
- **Dynamic Theming**: Matugen wallpaper extraction & live theme switcher (`<leader>un` / `<leader>up`).

---

[← Back to Main README](README.md)
