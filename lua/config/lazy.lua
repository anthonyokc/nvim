-- lazy.lua: Plugin manager setup using lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    defaults = {
        lazy = true, -- should plugins be lazy-loaded?
    },
    spec = "plugins",
    change_detection = { notify = false },
    rocks = {
        enabled = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml", -- 'tohtml' is 2html_plugin
                "tutor",
                "zipPlugin",
            },
        },
    },
})

