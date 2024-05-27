return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("nvim-tree").setup({
            update_focused_file = {
                enable = true
            },
        })

        local api = require "nvim-tree.api"
        vim.keymap.set("n", "<C-h>", api.tree.change_root_to_node)
        vim.keymap.set("n", "<C-g>", api.tree.toggle)
    end
}
