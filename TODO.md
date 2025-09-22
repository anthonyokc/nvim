# TODO List for Neovim Configuration

## Code Organization

- [ ] Extract LSP setup for each language into separate files within `config/lsp/`
- [ ] Move large keymapping sections in `remap.lua` into context-specific files
- [ ] Remaining keymapping sections should be logically grouped and labelled
- [ ] Implement auto-loading for the language-specific configurations based on filetype
- [ ] Organize larger init.lua files (like those in plugin subdirectories) into multiple smaller files


## Platform Support

- [ ] Add macOS-specific configuration
- [ ] Improve WSL detection and integration
- [ ] Test and fix issues on different Linux distributions
- [ ] Ensure proper functionality across different terminal emulators

## Plugin Improvements

- [X] Audit plugin list for duplicated functionality
- [ ] Add version pins for critical plugins
- [ ] Add plugin health checks and conditional configuration
- [ ] Improve unified notifications picker in telescope.lua to match native notify/noice formatting and preview capabilities

## R Language Support

- [ ] Configure httpgd as the default graphics device in Neovim
- [ ] Ensure quarto-nvim is configured correctly for R+Quarto workflows
- [ ] Implement R.nvim bindings for Send Paragraph and Send Chain commands
- [ ] Create a custom codegrip style implementation for R.nvim
- [ ] Submit PR to add treesitter-r support to Avante repo map

## AI Integration

- [ ] Integrate with [MCPHub.nvim](https://github.com/ravitemer/mcphub.nvim) for Avante
- [ ] Configure MCPHub Avante integration using system_prompt and custom_tools
- [ ] Consider adding blink.cmp fo
- [ ] Explore use of [Avante.nvim](https://github.com/yetone/avante.nvim) new Claude Text Editor Tool Mode
- [ ] Add diff preview for opencode.nvim file edits before saving (see lua/plugins/ai/opencode.lua)
- [ ] Move opencode.nvim helper functions to lua/config/ directory

## Documentation

- [ ] Add inline documentation for complicated functions
- [ ] Create a style guide for configuration contributions
- [ ] Document key bindings in a user-friendly format
- [ ] Add troubleshooting guide for common issues

## Cleanup

- [ ] Remove any deprecated plugin configurations
- [ ] Standardize naming conventions across all files
- [ ] Review and clean up commented-out code
- [ ] Audit global functions and variables for potential conflicts
