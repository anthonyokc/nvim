-- Description: Configuration for Git-related plugins and settings
-- Git-related configurations
local M = {}

M.setup = function()
    -- Git worktree settings
    vim.g.git_worktree = {
        change_directory_command = "cd",
        update_on_change = true,
        update_on_change_command = "e .",
        clearjumps_on_change = true,
        confirm_telescope_deletions = true,
        autopush = false,
    }
end

return M
