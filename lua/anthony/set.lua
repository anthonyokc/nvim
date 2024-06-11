vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false -- thank god
vim.opt.backup = false

-- Where to put the undo directory
local path_separator = package.config:sub(1,1)
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
vim.opt.listchars = 'space:·'

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

