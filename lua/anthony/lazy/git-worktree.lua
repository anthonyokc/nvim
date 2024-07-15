return {
    {
        "ThePrimeagen/git-worktree.nvim",
        config = function()
            require("git-worktree").setup({
                change_directory_command = "cd",
                update_on_change = true,
                update_on_change_command = "e .",
                clearjumps_on_change = true,
                autopush = false,
            })
        end,
    }
}
