# Neovim Configuration

A modular, organized Neovim configuration structured for maintainability and clarity.

## Structure Overview

```
nvim/
├── init.lua                 # Entry point that loads the config module
├── lua/
│   ├── config/              # Core configuration components
│   │   ├── autocmds.lua     # Autocommand definitions
│   │   ├── filetypes.lua    # Filetype-specific settings
│   │   ├── git.lua          # Git-related settings
│   │   ├── init.lua         # Main configuration loader
│   │   ├── lazy.lua         # Plugin manager setup
│   │   ├── remap.lua        # Key mappings
│   │   ├── set.lua          # Vim options
│   │   ├── util.lua         # Utility functions
│   │   ├── lang/            # Language-specific configurations
│   │   │   └── r.lua        # R language utilities and settings
│   │   └── system/          # OS-specific configurations
│   │       └── wsl.lua      # WSL integration settings
│   └── plugins/             # Plugin specifications
│       ├── init.lua         # Plugin loader that imports from subdirectories
│       ├── ai/              # AI-assisted coding plugins
│       ├── core/            # Core dependencies (e.g., plenary)
│       ├── debug/           # Debugging plugins
│       ├── editor/          # Text editing plugins
│       ├── fun/             # Fun/misc plugins
│       ├── git/             # Git integration plugins
│       ├── lang/            # Language-specific plugins
│       ├── lsp/             # LSP configurations
│       └── ui/              # UI enhancements
└── lazy-lock.json           # Plugin version lock file
```

## Configuration Details

### Core Configuration (`lua/config/`)

- **init.lua**: Bootstraps the entire configuration, loading all necessary modules
- **set.lua**: Sets up Vim options and basic behaviors
- **remap.lua**: Contains all key mappings
- **autocmds.lua**: Sets up automatic commands for various events
- **lazy.lua**: Configures the lazy.nvim plugin manager
- **util.lua**: Contains utility functions used throughout the configuration
- **filetypes.lua**: Sets up filetype detection and options
- **git.lua**: Git-related global settings
- **lang/**: Language-specific settings and utilities
- **system/**: OS-specific settings (WSL, macOS, Windows, etc.)

### Plugin Organization (`lua/plugins/`)

Plugins are organized into logical categories to maintain clarity and separation of concerns:

- **ai/**: AI-assisted coding tools (Copilot, ChatGPT, Avante)
- **core/**: Core dependencies required by other plugins
- **debug/**: Debugging tools (DAP, etc.)
- **editor/**: Editor enhancements (Telescope, Treesitter, etc.)
- **git/**: Git integration plugins (Fugitive, Gitsigns, etc.)
- **lang/**: Language-specific plugins (R, Quarto, etc.)
- **lsp/**: Language Server Protocol configurations
- **ui/**: User interface enhancements (colorschemes, statusline, etc.)
- **fun/**: Fun and miscellaneous plugins

## Usage

1. Clone this repository to `~/.config/nvim`
2. Start Neovim, and lazy.nvim will automatically install configured plugins

## Customization

- Add new core settings in the appropriate files in `lua/config/`
- Add new plugins by creating .lua files in the appropriate subdirectory in `lua/plugins/`
- Add language-specific settings in `lua/config/lang/`
- Add OS-specific settings in `lua/config/system/`

## How It Works

1. `init.lua` loads the main configuration module (`require("config")`)
2. `config/init.lua` loads all configuration components
3. `config/lazy.lua` initializes the plugin manager and loads plugins from `lua/plugins/`
4. `plugins/init.lua` recursively imports all plugin specs from subdirectories
