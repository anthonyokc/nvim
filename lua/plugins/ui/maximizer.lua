return {
    {
        "szw/vim-maximizer",
        keys = {
            { "<leader>k", "<cmd>MaximizerToggle<CR>", desc = "Maximize/restore current window" },
        },
        config = function()
            -- Optional configuration
            vim.g.maximizer_set_default_mapping = 0 -- Disable default mappings
            vim.g.maximizer_restore_on_winleave = 1 -- Restore on window leave
        end,
    },

}

