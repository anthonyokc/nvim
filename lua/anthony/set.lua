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
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

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

