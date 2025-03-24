require("config.remap")
require("config.set")
require("config.lazy")
require("config.autocmds")
require("config.filetypes")

function R(name)
    require("plenary.reload").reload_module(name)
end

-- Basic netrw settings
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Load OS-specific configurations
local in_wsl = os.getenv('WSL_DISTRO_NAME') ~= nil
if in_wsl then
    require("config.system.wsl").setup()
end

-- Load git configurations
require("config.git").setup()

-- Set terminal background to transparent
vim.cmd [[
    hi NvimTreeNormal guibg=NONE ctermbg=NONE
]]

-- Load utility functions and set up commands/keymaps
local util = require("config.util")
vim.api.nvim_create_user_command("WA", util.save_all_with_dirs, {})
vim.keymap.set("n", "<leader>j", util.toggle_window_size, { noremap = true, silent = true, desc = "Toggle window size to 50%" })

-- Load language-specific configurations
require("config.lang.r").setup()

-- Set up AI prompt toggle
vim.keymap.set("n", "<leader>am",
    function() vim.api.nvim_exec_autocmds("User", { pattern = "ToggleMyPrompt" }) end,
    { desc = "Avante: Toggle my prompt" })