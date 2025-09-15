return {
    {
        'kevinhwang91/nvim-ufo',
        event = 'BufReadPost',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            require('ufo').setup()
            vim.opt.foldlevelstart = 99
            vim.opt.foldlevel = 99
        end
    }
}
