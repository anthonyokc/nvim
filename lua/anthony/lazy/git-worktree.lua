return {
    -- {
    --     'polarmutex/git-worktree.nvim',
    --     version = '^2',
    --     dependencies = { "nvim-lua/plenary.nvim" },
    -- }
    -- {
    --     "zkygr/git-worktree.nvim",
    --     branch = "fix/create_branches_from_remote_ref",
    --     config = function()
    --         require("git-worktree").setup({
    --             change_directory_command = "cd",
    --             update_on_change = true,
    --             update_on_change_command = "v .",
    --             clearjumps_on_change = true,
    --             autopush = false,
    --         })
    --     end,
    -- },
    {
        "anthonyokc/git-worktree.nvim",
        config = function()
            require("git-worktree").setup({
                change_directory_command = "cd",
                update_on_change = true,
                update_on_change_command = "v .",
                clearjumps_on_change = true,
                autopush = false,
            })
        end,
    },
    -- {
    --     "ThePrimeagen/git-worktree.nvim",
    --     config = function()
    --         require("git-worktree").setup({
    --             change_directory_command = "cd",
    --             update_on_change = true,
    --             update_on_change_command = "v .",
    --             clearjumps_on_change = true,
    --             autopush = false,
    --         })
    --     end,
    -- },
}
