# ✦ Neovim configuration

Built to understand the editor, not just use it.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-blue.svg?style=flat-square&logo=neovim) ![Lua](https://img.shields.io/badge/Written_in-Lua-blue.svg?style=flat-square&logo=lua)

## Who built this

I'm Medhansh — 18, based in Chandigarh. I build from scratch before I reach for a framework.  
Not out of stubbornness. Because the day something breaks, you need to know what's underneath it.

This config is the same philosophy applied to my editor.

Most people inherit a Neovim config. Copy-paste from a Reddit thread, clone someone's dotfiles,  
run `:Lazy sync` and call it done. It works — until it doesn't. Then you're debugging someone  
else's abstractions with no idea what's underneath them.

I wanted to know what was underneath. So I built it myself.

Every plugin here has a reason. Every keybind was a decision. Nothing is in here because  
it came with a starter template.

If that sounds like how you think about software — this config might be useful to you.  
If you just want something that works out of the box, there are better options — [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), [LazyVim](https://github.com/LazyVim/LazyVim), [AstroNvim](https://github.com/AstroNvim/AstroNvim).

![screenshot](./assets/screenshot.png)

## Table of Contents

- [Who built this](#who-built-this)
- [Requirements](#requirements)
- [Installation](#installation)
- [Aesthetics](#aesthetics)
- [Plugins](#plugins)
- [Keybinds](#keybinds)
- [Special thanks](#special-thanks)

## Requirements

This configuration is built for performance and deep tool integration. To ensure everything (including image rendering, Jupyter notebooks, formatting, and linting) works correctly, you must install the following dependencies.

### Minimum version
*   **Neovim v0.10.0** or newer is strictly required.
*   **Python 3.11+** is recommended for full Molten and plugin support.

### System packages

#### Arch Linux
```bash
sudo pacman -S --needed neovim git curl ripgrep fd tree-sitter-cli nodejs npm \
  base-devel unzip python python-pip xdg-utils wl-clipboard man-db lazygit \
  imagemagick kitty make shfmt
```
For the custom dashboard (AUR):
```bash
yay -S pokemon-colorscripts-git
```

#### Debian / Ubuntu
```bash
sudo apt update
sudo apt install -y neovim git curl ripgrep fd-find tree-sitter-cli nodejs npm \
  build-essential unzip python3 python3-venv python3-pip xdg-utils wl-clipboard \
  man-db lazygit imagemagick kitty make shfmt
```
*Note: Symlink `fdfind` to `fd` for Telescope compatibility:*
```bash
mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
```

#### Fedora
```bash
sudo dnf install neovim git curl ripgrep fd-find tree-sitter-cli nodejs npm \
  development-tools unzip python3 python3-pip xdg-utils wl-clipboard \
  man-db lazygit imagemagick kitty make shfmt
```

#### macOS (Homebrew)
```bash
brew install neovim git ripgrep fd tree-sitter-cli node python lazygit \
  imagemagick make shfmt stylua
```

### Mandatory Python environment
The configuration uses a dedicated virtual environment for the Python provider and Jupyter (Molten) support. This prevents system-wide dependency conflicts.

```bash
# Create the venv
python -m venv ~/.venvs/neovim

# Install core dependencies
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat
```

### Dashboard ASCII art
This config uses `pokemon-colorscripts` for the startup screen.
*   **Arch**: Install `pokemon-colorscripts-git` from AUR.
*   **Others**: Follow the installation guide at [phakt/pokemon-colorscripts](https://gitlab.com/phakt/pokemon-colorscripts).

### Recommended terminal
**Kitty** is highly recommended as it provides the most robust support for the Kitty Graphics Protocol used by `snacks.image` and `molten-nvim` for inline image rendering.

![screenshot](./assets/screenshot.png)

## Installation

1. Back up your existing Neovim configuration if you have one.
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   mv ~/.local/share/nvim ~/.local/share/nvim.bak
   ```
2. Clone this repository directly into your config directory.
   ```bash
   git clone https://github.com/medhansh/nvim-config ~/.config/nvim
   ```
3. Launch Neovim.
   ```bash
   nvim
   ```

On the first boot, `lazy.nvim` will automatically bootstrap itself, clone all configured plugins, and install essential Treesitter parsers and LSP servers. You will see a UI popup displaying the installation progress. Wait for it to finish before opening any source code files.

## Aesthetics

*   **Colorscheme**: Dynamically managed via a custom utility. Defaults to [TokyoNight](https://github.com/folke/tokyonight.nvim), but seamlessly supports Catppuccin, Rose Pine, Kanagawa, Nightfox, Gruvbox, VSCode, Dracula, Everforest, Cyberdream, and Pywal.
*   **Font**: [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads), size 16 (configured via your terminal emulator).
*   **Transparency**: Editor chrome and floating windows are dynamically blended. You can toggle global background transparency on the fly using `<leader>uy`.
*   **Statusline**: Powered by `lualine.nvim` with a minimal, uncluttered design that integrates cleanly with the active colorscheme.

![theme preview](./assets/theme.png)

## Plugins

### Package management & core
| Plugin | Purpose |
| :--- | :--- |
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | Fast, feature-rich plugin manager |
| [folke/snacks.nvim](https://github.com/folke/snacks.nvim) | Swiss-army knife — dashboard, explorer, image viewer, picker, zen mode, notifications, smooth scroll, indent guides, and more |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | Displays a popup with possible key bindings |
| [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Core Lua functions used by many plugins |
| [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | Standard file icons |

### LSP, completion & snippets
| Plugin | Purpose |
| :--- | :--- |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Quickstart configs for Nvim LSP |
| [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) | Portable package manager for LSPs, linters, and formatters |
| [mason-org/mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Bridges mason.nvim with lspconfig |
| [WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Automatically installs 3rd party tools |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim) | Faster Lua LS setup for Neovim config |
| [b0o/schemastore.nvim](https://github.com/b0o/schemastore.nvim) | JSON/YAML schema validation |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine with LSP, buffer, path, and snippet sources |
| [onsails/lspkind.nvim](https://github.com/onsails/lspkind.nvim) | VSCode-like pictograms for completion |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Powerful snippet engine |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Collection of standard snippets |
| [SmiteshP/nvim-navic](https://github.com/SmiteshP/nvim-navic) | LSP breadcrumbs |

### Editing, formatting & linting
| Plugin | Purpose |
| :--- | :--- |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting, textobjects, and language parsing |
| [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Syntax-aware text objects |
| [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto close and rename HTML/JSX tags |
| [Wansmer/treesj](https://github.com/Wansmer/treesj) | Splitting/joining blocks of code |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Lightweight formatter setup |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) | Asynchronous linter |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets and quotes |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) | Smart commenting |
| [kylechui/nvim-surround](https://github.com/kylechui/nvim-surround) | Add/change/delete surrounding delimiters |
| [jake-stewart/multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) | Advanced multicursor support |
| [smjonas/inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim) | Incremental LSP renaming with live preview |
| [ThePrimeagen/refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | Refactoring library |
| [echasnovski/mini.ai](https://github.com/echasnovski/mini.ai) | Extended `a`/`i` textobjects |
| [gbprod/yanky.nvim](https://github.com/gbprod/yanky.nvim) | Improved yank and put with cycle history |
| [okuuva/auto-save.nvim](https://github.com/okuuva/auto-save.nvim) | Automatic file saving |

### Navigation & search
| Plugin | Purpose |
| :--- | :--- |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Highly extendable fuzzy finder |
| [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon) | Lightning fast file navigation |
| [folke/flash.nvim](https://github.com/folke/flash.nvim) | Navigate code with search labels |
| [MagicDuck/grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | Find and replace across the workspace |
| [stevearc/aerial.nvim](https://github.com/stevearc/aerial.nvim) | Code outline window |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics, references, and results list |
| [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and search TODO/NOTE/FIX comments |
| [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim) | Edit your filesystem like a buffer |
| [mbbill/undotree](https://github.com/mbbill/undotree) | Visual undo history |

### UI & visual enhancements
| Plugin | Purpose |
| :--- | :--- |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Blazing fast statusline |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer tab bar with diagnostics |
| [folke/noice.nvim](https://github.com/folke/noice.nvim) | Replaces the UI for messages, cmdline, and popupmenu |
| [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify) | Fancy notification manager |
| [OXY2DEV/helpview.nvim](https://github.com/OXY2DEV/helpview.nvim) | Fancy vimdoc/help viewer |
| [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) | High-performance color highlighter (supports ANSI) |
| [kevinhwang91/nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | Ultra fold in Neovim |
| [b0o/incline.nvim](https://github.com/b0o/incline.nvim) | Floating statuslines for split windows |
| [kevinhwang91/nvim-bqf](https://github.com/kevinhwang91/nvim-bqf) | Better quickfix window |
| [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate) | Highlight other uses of the word under cursor |
| [petertriho/nvim-scrollbar](https://github.com/petertriho/nvim-scrollbar) | Extensible scrollbar with diagnostics |
| [kevinhwang91/nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens) | Search lens for matches |
| [HiPhish/rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Rainbow-colored matching brackets |
| [sphamba/smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Smooth cursor trail animation |
| [tzachar/highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim) | Highlight changed text after undo/redo |
| [j-hui/fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress notifications |
| [m4xshen/smartcolumn.nvim](https://github.com/m4xshen/smartcolumn.nvim) | Smart color column that hides in non-code files |
| [stevearc/quicker.nvim](https://github.com/stevearc/quicker.nvim) | Quickfix list enhancements |
| [rachartier/tiny-code-action.nvim](https://github.com/rachartier/tiny-code-action.nvim) | Code actions with live diff preview |

### Git
| Plugin | Purpose |
| :--- | :--- |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git decorations via extmarks |
| [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit) | Magit clone for Neovim |
| [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) | Single-tabpage diff viewer |

### Development & debugging
| Plugin | Purpose |
| :--- | :--- |
| [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client |
| [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | UI for nvim-dap |
| [nvim-neotest/nvim-nio](https://github.com/nvim-neotest/nvim-nio) | Asynchronous IO |
| [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Virtual text for debug values |
| [mfussenegger/nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python debug adapter |
| [mxsdev/nvim-dap-vscode-js](https://github.com/mxsdev/nvim-dap-vscode-js) | VS Code JS debug adapter |
| [nvim-neotest/neotest](https://github.com/nvim-neotest/neotest) | Test framework with Python, Plenary, Jest, and GTest adapters |
| [CRAG666/code_runner.nvim](https://github.com/CRAG666/code_runner.nvim) | Quick code execution |
| [stevearc/overseer.nvim](https://github.com/stevearc/overseer.nvim) | Task runner and job management |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Persistent terminal windows |
| [rmagatti/auto-session](https://github.com/rmagatti/auto-session) | Session save and restore |
| [Civitasv/cmake-tools.nvim](https://github.com/Civitasv/cmake-tools.nvim) | CMake integration |
| [p00f/clangd_extensions.nvim](https://github.com/p00f/clangd_extensions.nvim) | Clangd LSP extensions |
| [linux-cultist/venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim) | Python virtualenv selector |
| [kristijanhusak/vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | Database UI with SQL execution |

### AI assistance
| Plugin | Purpose |
| :--- | :--- |
| [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot inline ghost text |
| [CopilotC-Nvim/CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) | Chat with Copilot in a split |
| [supermaven-inc/supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) | Supermaven AI code completion |
| [olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) | AI chat and inline assistant |

### Notes & markdown
| Plugin | Purpose |
| :--- | :--- |
| [epwalsh/obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) | Obsidian vault integration and note management |
| [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Rich in-buffer markdown rendering |
| [Kicamon/markdown-table-mode.nvim](https://github.com/Kicamon/markdown-table-mode.nvim) | Markdown table formatting and wrapping |
| [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser-based markdown preview |
| [benlubas/molten-nvim](https://github.com/benlubas/molten-nvim) | Interactive Jupyter REPL and notebook runner |
| [3rd/image.nvim](https://github.com/3rd/image.nvim) | Kitty protocol image rendering (Molten output cells) |
| [dkarter/bullets.vim](https://github.com/dkarter/bullets.vim) | Bullet list continuation |
| [gaoDean/autolist.nvim](https://github.com/gaoDean/autolist.nvim) | Automatic list continuation and formatting |

### Themes & colorschemes
| Plugin | Purpose |
| :--- | :--- |
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Default — clean, dark theme |
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Soothing pastel theme |
| [rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Japanese painting-inspired palette |
| [rose-pine/neovim](https://github.com/rose-pine/neovim) | All natural pine with soho vibes |
| [EdenEast/nightfox.nvim](https://github.com/EdenEast/nightfox.nvim) | Highly customizable theme |
| [ellisonleao/gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) | The classic retro groove |
| [Mofiqul/vscode.nvim](https://github.com/Mofiqul/vscode.nvim) | VS Code dark/light theme |
| [Mofiqul/dracula.nvim](https://github.com/Mofiqul/dracula.nvim) | Dracula colorscheme |
| [sainnhe/everforest](https://github.com/sainnhe/everforest) | Green-based comfortable colorscheme |
| [scottmckendry/cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) | High-contrast futuristic theme |
| [AlphaTechnolog/pywal.nvim](https://github.com/AlphaTechnolog/pywal.nvim) | Pywal-generated colors |

## Keybinds

The leader key is set to `<Space>`.

Note: `<C-x>` refers to pressing `Control` and `x` simultaneously. `<M-x>` refers to the `Alt` (or Option) key. 

### Normal mode

#### Files, Buffers & Search
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>e` | Open or close the file sidebar | snacks.explorer |
| `<leader>fe` | Open the classic netrw file list | Builtin |
| `<leader>fs` | Save the current file | Builtin |
| `<leader>q` | Quit the current window | Builtin |
| `q` | Close buffer (in help/man pages) | Builtin |
| `<leader>bb` | Browse open buffers | Telescope |
| `<leader>bn` | Go to the next buffer | Builtin |
| `<leader>bp` | Go to the previous buffer | Builtin |
| `<leader>bd` | Delete the current buffer | snacks.bufdelete |
| `<leader>bo` | Delete every other buffer | Builtin |
| `<C-1>` to `<C-9>` | Go to buffer 1-9 | Builtin |
| `<leader>p` | Open the command palette | Telescope |
| `<leader>ff` | Find a file by name | Telescope |
| `<leader>fg` | Search for text in the project | Telescope |
| `<leader>f/` | Search in the current file | Telescope |
| `<leader>fb` | Switch between open files | Telescope |
| `<leader>fp` | Find a tracked project file | Telescope |
| `<leader>fr` | Reopen a recent file | Telescope |
| `<leader>fS` | Search symbols in this file | Telescope |
| `<leader>fw` | Search workspace symbols | Telescope |
| `<leader>ft` | Find every TODO, NOTE, or FIX comment | todo-comments.nvim |
| `<leader>fk` | Browse every keybinding | Custom / Telescope |
| `<leader>?` | Browse every keybinding | Custom / Telescope |
| `<leader>sr` | Search and replace across the project | grug-far.nvim |
| `<leader>sw` | Search for the word under the cursor across the project | grug-far.nvim |
| `<leader>sB` | Search and replace only in the current file | grug-far.nvim |
| `<leader>si` | Browse images (floating preview) | snacks.picker |
| `<leader>sj` | Jump (flash) | flash.nvim |
| `<leader>ss` | Treesitter jump (flash) | flash.nvim |
| `<leader>ha` | Add to harpoon | Harpoon |
| `<leader>hh` | Toggle harpoon menu | Harpoon |
| `<leader>h1` to `<leader>h4` | Harpoon file 1-4 | Harpoon |

#### LSP, Formatting & Diagnostics
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>cf` | Format the current file | conform.nvim |
| `<leader>uf` | Toggle auto-format on save | conform.nvim |
| `<leader>ca` | Code actions (visual preview) | tiny-code-action.nvim |
| `<leader>rn` | Rename symbol (incremental preview) | inc-rename.nvim |
| `gd` | Go to definition | LSP |
| `gD` | Go to declaration | LSP |
| `gi` | Go to implementation | LSP |
| `gr` | Go to references | LSP |
| `K` | Hover documentation | LSP |
| `<leader>ld` | Explain problem (cursor) | LSP |
| `<leader>lD` | Jump to declaration | LSP |
| `<leader>le` | Explain problem (float) | LSP |
| `<leader>li` | Jump to implementation | LSP |
| `<leader>lI` | Toggle inlay hints | LSP |
| `<leader>lk` | Signature help | LSP |
| `<leader>lo` | Document symbols | LSP |
| `<leader>lR` | LSP Restart | LSP |
| `<leader>ls` | Workspace symbols | LSP |
| `<leader>lt` | Type definition | LSP |
| `[d` | Previous Diagnostic | Builtin |
| `]d` | Next Diagnostic | Builtin |
| `<leader>xd` | Buffer diagnostics | trouble.nvim |
| `<leader>xl` | Location list | trouble.nvim |
| `<leader>xo` | Document symbols side | trouble.nvim |
| `<leader>xq` | Quickfix list | trouble.nvim |
| `<leader>xx` | Project diagnostics | trouble.nvim |

#### Git Operations
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `]h` | Next hunk (motion) | gitsigns.nvim |
| `[h` | Previous hunk (motion) | gitsigns.nvim |
| `<leader>gn` | Next hunk (explicit) | gitsigns.nvim |
| `<leader>gp` | Previous hunk (explicit) | gitsigns.nvim |
| `<leader>gs` | Stage this changed block | gitsigns.nvim |
| `<leader>gu` | Undo staging for this changed block | gitsigns.nvim |
| `<leader>gr` | Discard this changed block | gitsigns.nvim |
| `<leader>gb` | Show who changed this line and when | gitsigns.nvim |
| `<leader>gd` | Preview this changed block | gitsigns.nvim |
| `<leader>gD` | Compare this file against git | gitsigns.nvim |
| `<leader>gg` | Open the full git panel | Neogit |
| `<leader>gc` | Start a git commit | Neogit |
| `<leader>gl` | Open Lazygit | snacks.lazygit |
| `<leader>gf` | Lazygit current file history | snacks.lazygit |
| `<leader>gB` | Open git permalink in browser | snacks.gitbrowse |

#### Terminal, Tasks & Debugging
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>rr` | Run the current file | code_runner.nvim |
| `<leader>to` | Open or close the floating terminal | toggleterm.nvim |
| `<leader>tf` | Open the main project shell | toggleterm.nvim |
| `<leader>th` | Open a bottom terminal panel | toggleterm.nvim |
| `<leader>tv` | Open a side terminal panel | toggleterm.nvim |
| `<leader>tg` | Pick from active terminal sessions | toggleterm.nvim |
| `<leader>ta` | Task quick action | overseer.nvim |
| `<leader>tl` | Load task bundle | overseer.nvim |
| `<leader>tr` | Run task | overseer.nvim |
| `<leader>tt` | Toggle task list | overseer.nvim |
| `<leader>db` | Toggle breakpoint | nvim-dap |
| `<leader>dc` | Continue | nvim-dap |
| `<leader>di` | Step into | nvim-dap |
| `<leader>do` | Step over | nvim-dap |
| `<leader>dO` | Step out | nvim-dap |
| `<leader>dr` | Toggle REPL | nvim-dap |
| `<leader>dt` | Terminate | nvim-dap |
| `<leader>du` | Toggle UI | nvim-dap-ui |

#### Notes & Markdown
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>zz` | Focus on writing without distractions | snacks.zen |
| `<leader>z` | Toggle Zen Mode | snacks.zen |
| `<leader>Z` | Toggle Zoom Mode | snacks.zen |
| `<leader>zw` | Toggle low-noise writing mode for this buffer | Custom utils |
| `<leader>zb` | Toggle Brainstorm mode (Universal) | Custom utils |
| `<leader>ns` | Strikeout the word under the cursor | Builtin |
| `<leader>np` | Open or close the markdown browser preview | markdown-preview.nvim |
| `<leader>nB` | Markdown: Brainstorm Mode | Custom utils |
| `<leader>nP` | Markdown: Professional Mode | Custom utils |
| `<leader>no` | Open the document or code outline | aerial.nvim |
| `<leader>nn` | Open outline navigation in a floating picker | aerial.nvim |
| `<leader>ih` | Hover image preview | snacks.image |
| `<leader>os` | Obsidian: Search notes | obsidian.nvim |
| `<leader>of` | Obsidian: Find notes | obsidian.nvim |
| `<leader>on` | Obsidian: New note | obsidian.nvim |
| `<leader>ot` | Obsidian: Today's daily note | obsidian.nvim |
| `<leader>oy` | Obsidian: Yesterday's daily note | obsidian.nvim |
| `<leader>ob` | Obsidian: Show backlinks | obsidian.nvim |
| `<leader>ol` | Obsidian: Show links in current note | obsidian.nvim |
| `<leader>oi` | Obsidian: Paste image from clipboard | obsidian.nvim |
| `<leader>ch` | Toggle checkbox (Obsidian) | obsidian.nvim |
| `<leader>mi` | Initialize Molten and pick a kernel | molten-nvim |
| `<leader>me` | Evaluate an operator selection | molten-nvim |
| `<leader>ml` | Evaluate the current line | molten-nvim |
| `<leader>md` | Delete the current Molten cell | molten-nvim |
| `<leader>mh` | Hide Molten output | molten-nvim |
| `<leader>ms` | Show Molten output | molten-nvim |
| `<leader>mr` | Restart the active Molten kernel | molten-nvim |
| `<leader>mo` | Open the current Molten output in a browser | molten-nvim |

#### Folds
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>fo` | Open the fold under the cursor completely | Builtin |
| `<leader>fc` | Close the fold under the cursor completely | Builtin |
| `<leader>fa` | Toggle the fold under the cursor | Builtin |
| `<leader>fv` | Preview folded lines under the cursor | nvim-ufo |
| `<leader>fR` | Open every fold in the file | nvim-ufo |
| `<leader>fM` | Close every fold in the file | nvim-ufo |
| `<leader>za` | Toggle fold | Builtin |
| `<leader>zc` | Close fold | Builtin |
| `<leader>zM` | Close all folds | Builtin |
| `<leader>zo` | Open fold | Builtin |
| `<leader>zR` | Open all folds | Builtin |
| `<leader>zv` | Preview fold | Builtin |

#### UI Toggles & Window Management
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>hvt` | Toggle Helpview | helpview.nvim |
| `<leader>hvs` | Toggle Helpview Split | helpview.nvim |
| `<leader>hvr` | Refresh Helpview | helpview.nvim |
| `<leader>ut` | Choose a theme | Custom theme utility |
| `<leader>un` | Switch to the next theme | Custom theme utility |
| `<leader>up` | Switch to the previous theme | Custom theme utility |
| `<leader>us` | Toggle spell check | Builtin |
| `<leader>uy` | Turn transparency on or off | Custom theme utility |
| `<leader>ua` | Turn autosave on or off (global) | auto-save.nvim |
| `<leader>ub` | Turn autosave on or off for this file | auto-save.nvim |
| `<leader>uw` | Toggle text wrapping | Builtin |
| `<leader>wv` | Split the window vertically | Builtin |
| `<leader>wh` | Split the window horizontally | Builtin |
| `<leader>wc` | Close the current window | Builtin |
| `<leader>wo` | Keep only the current window | Builtin |
| `<leader>wm` | Maximize / Zoom window | snacks.toggle |
| `<leader>wr` | Restore session | auto-session |
| `<leader>ws` | Save session | auto-session |
| `<leader>.` | Toggle scratch buffer | snacks.scratch |
| `<leader>S` | Select scratch buffer | snacks.scratch |
| `<leader>n` | Notification history | snacks.notifier |
| `<leader>cR` | Rename file (LSP) | snacks.rename |

#### Multicursor
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>Ma` | Add the next matching cursor | multicursor.nvim |
| `<leader>MA` | Add cursors for every match in the file | multicursor.nvim |
| `<leader>Ms` | Skip the next matching cursor | multicursor.nvim |
| `<leader>Mv` | Restore the last cleared multicursor set | multicursor.nvim |
| `<leader>Mx` | Delete current multicursor | multicursor.nvim |
| `<leader>Mt` | Toggle multicursor for current match | multicursor.nvim |
| `<leader>Mj` | Add cursor below | multicursor.nvim |
| `<leader>Mk` | Add cursor above | multicursor.nvim |
| `<leader>MJ` | Skip cursor below | multicursor.nvim |
| `<leader>MK` | Skip cursor above | multicursor.nvim |
| `<C-M-Up>` | Add cursor above | multicursor.nvim |
| `<C-M-Down>` | Add cursor below | multicursor.nvim |

### Insert mode
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<C-Space>` | Trigger autocomplete | nvim-cmp |
| `<C-e>` | Abort autocomplete | nvim-cmp |
| `<CR>` | Confirm completion selection | nvim-cmp |
| `<C-\>` | Toggle terminal | toggleterm.nvim |

### Visual mode
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<leader>ns` | Strikeout the selection | Builtin |
| `<leader>ca` | Range code action | LSP |
| `<leader>sr` | Search and replace within selection | grug-far.nvim |
| `<leader>on` | Obsidian: Link selection to new note | obsidian.nvim |
| `<leader>ol` | Obsidian: Link selection to existing note | obsidian.nvim |
| `<leader>mv` | Evaluate the visual selection | molten-nvim |
| `<leader>Mj` | Add cursor below | multicursor.nvim |
| `<leader>Mk` | Add cursor above | multicursor.nvim |
| `<leader>MJ` | Skip cursor below | multicursor.nvim |
| `<leader>MK` | Skip cursor above | multicursor.nvim |
| `<C-M-Up>` | Add cursor above | multicursor.nvim |
| `<C-M-Down>` | Add cursor below | multicursor.nvim |
| `J` | Move selected block down | Builtin |
| `K` | Move selected block up | Builtin |

### Terminal mode
| Key | Action | Plugin/builtin |
| :--- | :--- | :--- |
| `<C-\>` | Toggle terminal window | toggleterm.nvim |
| `<C-\><C-n>` | Exit terminal insert mode | Builtin |

## Special thanks

* [LazyVim](https://github.com/LazyVim/LazyVim) - For setting the modern standard of how a modular Neovim configuration should be structured.
* [NvChad](https://github.com/NvChad/NvChad) - For endless inspiration on UI aesthetics and dynamic themes.

Contributions, tweaks, and suggestions are welcome via pull requests.