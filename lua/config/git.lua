-- Description: Configuration for Git-related plugins and settings
-- Git-related configurations
local M = {}

M.switch_to_related_diffwin_and_close = function()
    local cur_win = vim.api.nvim_get_current_win()
    local cur_name = vim.api.nvim_buf_get_name(0)
    if cur_name == '' then return end
    local base = vim.fn.fnamemodify(cur_name, ':t')
    local wins = vim.api.nvim_tabpage_list_wins(0)
    local candidate
    local gitsigns_candidate
    for _, win in ipairs(wins) do
        if win ~= cur_win then
            local ok, winopts = pcall(function() return vim.wo[win] end)
            if ok and winopts and winopts.diff then
                local b = vim.api.nvim_win_get_buf(win)
                local name = vim.api.nvim_buf_get_name(b)
                if vim.fn.fnamemodify(name, ':t') == base then
                    if name:match('^gitsigns://') then
                        gitsigns_candidate = win
                        break
                    else
                        candidate = win
                    end
                end
            end
        end
    end
    local target = gitsigns_candidate or candidate
    if target then
        vim.api.nvim_set_current_win(target)
        pcall(vim.cmd.close)
    end
end

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
