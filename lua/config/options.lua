-- options.lua: Neovim options configuration
-- Start with "vim.opt."
-- These are different than globals which start with "vim.g." those are in globals.lua
-- See :help options for a list of options
-- See :help vim.opt for how to use vim.opt
vim.opt.nu = true
vim.opt.relativenumber = true

-- Set tabs and indentation based on file type (using autocmd)
vim.opt.tabstop = 2 -- Number of spaces a <Tab> in the file counts for
vim.opt.softtabstop = 2 -- Number of spaces a <Tab> counts for while performing editing operations
vim.opt.shiftwidth = 2 -- Indent by 4 spaces when using >> or <<
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.smartindent = true

vim.opt.wrap = false -- No line wrappingk
vim.opt.textwidth = 80 -- Set maximum text width to 80 characters

vim.opt.showmode = false -- we don't need to see things like "-- INSERT --" anymore

vim.opt.swapfile = false -- thank god
vim.opt.backup = false

-- Where to put the undo directory
local path_separator = package.config:sub(1, 1)
local home_directory = os.getenv("HOME") or os.getenv("USERPROFILE") -- USERPROFILE is used in Windows
vim.opt.undodir = home_directory .. path_separator .. ".vim" .. path_separator .. "undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true -- enables 24-bit color

-- disbale netrw (default file tree) to use nvim-tree instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.opt.list = true
vim.opt.listchars = "space:·,tab:→·"

-- -- Set Tabs for specific files
-- local set_tab_settings = function(extension, ts, sw, sts)
--   vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
--     pattern = "*" .. extension,
--     callback = function()
--       vim.bo.tabstop = ts
--       vim.bo.shiftwidth = sw
--       vim.bo.softtabstop = sts
--     end,
--   })
-- end
--
-- -- Set tab settings for R files
-- set_tab_settings(".R|.Rmd|.qmd", 2, 2, 2)
