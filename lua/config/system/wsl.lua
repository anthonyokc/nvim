-- WSL-specific configuration
local M = {}

M.setup = function()
    -- Configure clipboard integration with Windows
    -- vim.g.clipboard = {
    --     name = 'wsl clipboard',
    --     copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
    --     paste = { ["+"] = { "nvim_paste" }, ["*"] = { "nvim_paste" } },
    --     cache_enabled = true
    -- }
    vim.g.clipboard = 'osc52'
end

return M
