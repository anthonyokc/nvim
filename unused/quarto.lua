return {

    { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
        -- for complete functionality (language features)
        'quarto-dev/quarto-nvim',
        ft = { 'quarto', 'qmd'},
        dev = false,
        config = function()
            require('quarto').setup()
        end,
        dependencies = {
            -- for language features in code cells
            -- configured in lua/plugins/lsp.lua and
            -- added as a nvim-cmp source in lua/plugins/completion.lua
            'jmbuhr/otter.nvim',
            "nvim-treesitter/nvim-treesitter",
        },
    },

}
