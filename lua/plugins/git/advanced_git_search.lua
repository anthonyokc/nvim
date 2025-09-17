return {
    "aaronhallaert/advanced-git-search.nvim",
    cmd = { "AdvancedGitSearch" },
    dependencies = {
        "nvim-telescope/telescope.nvim", -- to show diff splits and open commits in browser
        "tpope/vim-fugitive",            -- to open commits in browser with fugitive
        "tpope/vim-rhubarb",
        -- optional: to replace the diff from fugitive with diffview.nvim (fugitive is still needed to open in browser)
        "sindrets/diffview.nvim",
    },
    opts = {
        diff_plugin = "diffview", -- "fugitive", "diffview" or "none"
        git_flags = { "-c", "delta.side-by-side=true" },
        git_diff_flags = { "-c", "delta.side-by-side=true" },
        git_log_flags = {},
    },
    config = function(_, opts)
        local ok, config = pcall(require, "advanced_git_search.utils.config")
        if not ok then
            vim.notify("advanced-git-search config not available", vim.log.levels.ERROR)
            return
        end

        config.setup(opts)
    end,
}
