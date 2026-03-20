return {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    config = function()
        require("nvim-tree").setup({
            update_focused_file = {
                enable = true
            },
            view = {
                float = {
                    enable = true,
                    open_win_config = {
                        height = 70,
                        width = 50
                    }
                },
            },
            filters = {
                enable = false, -- Start with filters disabled, toggle with keybinding
            },
        })

        local api = require "nvim-tree.api"
        -- api.tree.open() -- open the tree automatically, do not focus on it though


        -- key bindings
        vim.keymap.set("n", "<leader>oo", api.tree.change_root_to_node, { desc = "Open nvim-tree at current file" })
        vim.keymap.set("n", "<C-g>", api.tree.toggle)

        -- Toggle filters
        vim.keymap.set("n", "<leader>th", api.tree.toggle_hidden_filter, { desc = "Toggle dotfiles" })
        vim.keymap.set("n", "<leader>ti", api.tree.toggle_gitignore_filter, { desc = "Toggle gitignore" })
    end
}
