return {
    "nvim-pack/nvim-spectre",
    keys = {
        { "<leader>Ss", desc = "Toggle Spectre" },
        { "<leader>SS", desc = "Toggle Spectre" },
        { "<leader>Sw", desc = "Search current word" },
        { "<leader>Sp", desc = "Search on current file" },
    },
    config = function()
        require('spectre').setup({
            open_cmd = 'tabnew',
            is_insert_mode = false,
        })
        vim.keymap.set('n', '<leader>Ss', '<cmd>lua require("spectre").toggle()<CR>', {
            desc = "Toggle Spectre"
        })
        vim.keymap.set('n', '<leader>SS', '<cmd>lua require("spectre").toggle()<CR>', {
            desc = "Toggle Spectre"
        })
        vim.keymap.set('n', '<leader>Sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
            desc = "Search current word"
        })
        vim.keymap.set('v', '<leader>Sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
            desc = "Search current word"
        })
        vim.keymap.set('n', '<leader>Sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
            desc = "Search on current file"
        })
    end
}
