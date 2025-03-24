# TODO List for Neovim Configuration

## Code Organization

- [ ] Extract LSP setup for each language into separate files within `config/lsp/`
- [ ] Move large keymapping sections in `remap.lua` into context-specific files
- [ ] Remaining keymapping sections should be logically grouped and labelled
- [ ] Implement auto-loading for the language-specific configurations based on filetype
- [ ] Add conditional loading for heavy plugins to improve startup time
- [ ] Organize larger init.lua files (like those in plugin subdirectories) into multiple smaller files


## Performance

- [ ] Profile startup time and optimize slow-loading plugins
- [ ] Implement lazy-loading for more plugins based on events/commands
- [ ] Cache results of expensive operations
- [ ] Review and optimize autocmd usage

## Platform Support

- [ ] Add macOS-specific configuration
- [ ] Improve WSL detection and integration
- [ ] Test and fix issues on different Linux distributions
- [ ] Ensure proper functionality across different terminal emulators

## Plugin Improvements

- [ ] Audit plugin list for duplicated functionality
- [ ] Add version pins for critical plugins
- [ ] Add plugin health checks and conditional configuration

## R Language Support

- [ ] Configure httpgd as the default graphics device in Neovim
- [ ] Ensure quarto-nvim is configured correctly for R+Quarto workflows
- [ ] Implement R.nvim bindings for Send Paragraph and Send Chain commands
- [ ] Create a custom codegrip style implementation for R.nvim
- [ ] Submit PR to add treesitter-r support to Avante repo map

## AI Integration

- [ ] Integrate with [MCPHub.nvim](https://github.com/ravitemer/mcphub.nvim) for Avante 
- [ ] Configure MCPHub Avante integration using system_prompt and custom_tools
- [ ] Consider adding blink.cmp fo- [ ] Explore use of
  [Avante.nvim](https://github.com/yetone/avante.nvim) new  Claude Text
  Editor Tool Mode

## Documentation

- [ ] Add inline documentation for complicated functions
- [ ] Create a style guide for configuration contributions
- [ ] Document key bindings in a user-friendly format
- [ ] Add troubleshooting guide for common issues

## Testing

- [ ] Create a minimal test environment for validating configuration changes
- [ ] Add checks for configuration load errors
- [ ] Implement automated tests for critical functionality
- [ ] Create a CI pipeline to validate changes on different platforms

## Cleanup

- [ ] Remove any deprecated plugin configurations
- [ ] Standardize naming conventions across all files
- [ ] Review and clean up commented-out code
- [ ] Audit global functions and variables for potential conflicts