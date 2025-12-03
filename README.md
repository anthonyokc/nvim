# Neovim Configuration

A modular Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim) helpers, with plugins split into focused categories.

## Layout

```
nvim/
├── init.lua                 # Entry point that loads the config module
├── lua/
│   ├── config/              # Core configuration
│   │   ├── init.lua         # Loads options, keymaps, autocmds, lazy, file types
│   │   ├── options.lua      # Editor options
│   │   ├── keymap.lua       # Key mappings
│   │   ├── autocmds.lua     # Autocommands
│   │   ├── file_types.lua   # Filetype defaults
│   │   ├── globals.lua      # Global variables
│   │   ├── git.lua          # Git-specific settings
│   │   ├── git-worktree-helpers.lua
│   │   ├── lazy.lua         # lazy.nvim bootstrap
│   │   ├── lazyvim/         # LazyVim-style defaults, icons, and options
│   │   ├── ai/              # AI config (e.g., OpenCode prompts)
│   │   ├── languages/       # Language-specific setup (R, etc.)
│   │   └── system/          # OS-specific settings (WSL, Windows)
│   ├── plugins/             # Plugin specs grouped by purpose
│   │   ├── init.lua         # Imports each subdirectory
│   │   ├── ai/              # Avante, Copilot, ChatGPT, OpenCode, MCP hub
│   │   ├── debugger/        # DAP and related helpers
│   │   ├── editor/          # Treesitter, Telescope, Harpoon, snippets, etc.
│   │   ├── git/             # Gitsigns, Diffview, Lazygit, worktree tooling
│   │   ├── goofing/         # Fun/experimental plugins
│   │   ├── languages/       # Markdown, Quarto, R, SQL, HTML, REPLs, compilers
│   │   ├── lsp/             # LSP core, completion, diagnostics
│   │   └── ui/              # Colors, statusline, dashboard, tabs, notifications
│   └── util/                # Shared helpers (LazyVim utilities, statusline, roots)
└── lazy-lock.json           # Plugin version lock file
```

## Configuration Flow

1. Neovim starts and `init.lua` loads `config/init.lua`.
2. `config/init.lua` wires up core pieces first (options, keymaps, autocmds, filetype rules) and then bootstraps Lazy via `config/lazy.lua`.
3. The same entry point applies OS-specific tweaks (e.g., WSL clipboard), git helpers, language setup (R), and utility keybindings.
4. `config/lazy.lua` ensures [lazy.nvim](https://github.com/folke/lazy.nvim) is on the runtimepath and points it at `plugins/init.lua`.
5. `plugins/init.lua` imports each plugin category; lazy.nvim then lazy-loads individual specs as events/commands/filetypes are hit.
6. Shared defaults and icons live in `config/lazyvim/` and are consumed by plugin specs and utilities.

## Feature Highlights

- Fast startup with lazy-loaded plugins grouped by category (UI, LSP, git, editor tools, AI, debugger, language packs).
- Utility commands: `:WA` saves all buffers while creating missing dirs; `<leader>j` toggles the current window to 50% width; `<leader>ot` triggers an Opencode prompt and resizes the REPL if there is one.
- Git tooling: Gitsigns, Diffview, Lazygit, and worktree helpers for quick branch/worktree switches.
- Navigation and editing: Telescope pickers, Treesitter, Harpoon, surround/undo/indent helpers, snippets, table of contents, and text wrapping tools.
- UI polish: Colorscheme via lazy-loaded themes, statusline utilities, dashboard, tabs, notifications, and icon support.
- AI helpers: OpenCode and Copilot primarily. Many custom OpenCode.nvim enhancements. Also includes Avante, ChatGPT, and MCP integrations with convenient keybindings.

### R configuration

- Use radian as REPL.
- View data with visidata. View data up to select parts of a pipe chain (even if there's an assignment!).
- Filetype autocmds for `r`, `rmd`, and `quarto` set buffer-local keymaps:
  - `<leader>C` toggles comment on current line or selection.
  - `<leader>rf` / `<leader>ru` format/unformat function calls to multiline or single-line.
  - `<leader>ra` toggles assigning the current pipe chain (`name <- name |> ...`).
  - `<leader>rp` toggles a trailing native pipe (`|>`) on the current line.
- Custom fold expression for R headings (`#`, `##`, `###`) with folds enabled by default in R buffers.
- Helpers to assign defaults from the function under cursor into the R environment (expects R.nvim to be running and ready to receive commands).

## Using and Customizing

1. Clone to `~/.config/nvim` and start Neovim; [lazy.nvim](https://github.com/folke/lazy.nvim) will install the pinned plugins from `lazy-lock.json`.
2. Adjust core behavior in `lua/config/` (options, keymaps, file types, git helpers, OS-specific tweaks).
3. Add or tune plugins by dropping specs into the appropriate folder under `lua/plugins/`.
4. Extend shared helpers in `lua/util/` if you need new statusline/root/markdown utilities.

### Installing the lockfile with Lazy

- After cloning, open Neovim and run `:Lazy restore` to install the exact plugin versions pinned in `lazy-lock.json` (use `:Lazy sync` if you also changed specs).
- If you modify plugins and need to refresh the lockfile, run `:Lazy lock` and commit the updated `lazy-lock.json`.

## Attributions

- Core utility layer (`lua/util` and `lua/config/lazyvim/*`) and several plugin specs are adapted from the LazyVim project and its default configuration.
- Plugin management and locking rely on [lazy.nvim](https://github.com/folke/lazy.nvim).
- Many individual plugin setups borrow patterns from their upstream READMEs and community dotfiles; there are likely more influences than can be comprehensively listed here.
