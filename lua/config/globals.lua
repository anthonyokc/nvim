-- globals.lua: neovim global variables
-- These start with "vim.g."

-- Basic netrw settings
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Loader
vim.loader.enable(true)  -- Neovim's Lua module cache

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider   = 0
vim.g.loaded_perl_provider   = 0
vim.g.loaded_node_provider   = 0

