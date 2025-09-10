return {
    {
        'kevinhwang91/nvim-ufo',
        event = 'BufReadPost',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            require('ufo').setup()
            vim.opt.foldlevel = 100
        end
    }
}
