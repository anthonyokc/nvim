return {
    "AckslD/nvim-neoclip.lua",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        { 'nvim-telescope/telescope.nvim' },
    },
    config = function()
        require('neoclip').setup()
    end,
}
