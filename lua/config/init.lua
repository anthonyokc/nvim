-- init.lua: Initialization file for Neovim configuration
-- This file loads various configuration modules
-- It should not contain any actual configuration settings itself
require("config.keymap")
require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.file_types")

-- Load OS-specific configurations
local in_wsl = os.getenv('WSL_DISTRO_NAME') ~= nil
if in_wsl then
    require("config.system.wsl").setup()
else
    vim.g.clipboard = 'osc52'
end

-- Load git configurations
require("config.git").setup()

-- Set terminal background to transparent
vim.cmd [[
    hi NvimTreeNormal guibg=NONE ctermbg=NONE
]]

-- Load utility functions and set up commands/keymaps
local util = require("config.util")
vim.api.nvim_create_user_command("WS", util.save_with_dirs, {})
vim.api.nvim_create_user_command("WA", util.save_all_with_dirs, {})
vim.keymap.set("n", "<leader>ws", util.save_with_dirs, { desc = "Save file + mkdir parents" })
vim.keymap.set("n", "<leader>j", util.toggle_window_size,
    { noremap = true, silent = true, desc = "Toggle window size to 50%" })

-- Load language-specific configurations
require("config.languages.r").setup()

-- Set up AI prompt toggle
vim.keymap.set("n", "<leader>am",
    function() vim.api.nvim_exec_autocmds("User", { pattern = "ToggleMyPrompt" }) end,
    { desc = "Avante: Toggle my prompt" })

local M = {}

---@param opts? LazyVimConfig
function M.setup(opts)
  require("config.lazyvim").setup(opts)
end

return M
