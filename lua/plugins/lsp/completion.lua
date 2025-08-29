return {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter',
    dependencies = {
        -- Snippet completion
        'L3MON4D3/LuaSnip', -- the snippet engine
        'rafamadriz/friendly-snippets', -- snippet collections

        -- Specialized completions
        'jmbuhr/otter.nvim', -- specialized completion for Quarto and RMarkdown documents
    },
    config = function()
        local blink = require('blink.cmp')
        local luasnip = require('luasnip')

        blink.setup({
            keymap = {
                preset = 'default',
                ['<C-e>'] = { 'hide' },
                ['<C-y>'] = { 'select_and_accept' },
                ['<Tab>'] = { 'select_and_accept' },
                -- Snippet navigation
                ['<M-j>'] = {
                    function(cmp)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            cmp.select_next()
                        end
                    end,
                    'snippet_forward',
                    'fallback'
                },
                ['<M-k>'] = {
                    function(cmp)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            cmp.select_prev()
                        end
                    end,
                    'snippet_backward',
                    'fallback'
                },
            },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer'},
                providers = {
                    buffer = {
                        name = 'Buffer',
                        module = 'blink.cmp.sources.buffer',
                        max_items = 3,
                        min_keyword_length = 5,
                        enabled = function()
                            local ft = vim.bo.filetype
                            return ft ~= 'lua' or vim.api.nvim_buf_line_count(0) < 1000
                        end
                    },
                    otter = {
                        name = 'Otter',
                        module = 'blink.cmp.sources.otter',
                        score_offset = 100,
                        enabled = function()
                            return vim.tbl_contains({ 'quarto', 'markdown' }, vim.bo.filetype)
                        end
                    },
                    latex_symbols = {
                        name = 'LaTeX Symbols',
                        module = 'blink.cmp.sources.latex_symbols',
                        score_offset = 15,
                        enabled = function()
                            return vim.tbl_contains({ 'tex', 'latex' }, vim.bo.filetype)
                        end
                    },
                },
            },

            completion = {
                menu = {
                    border = 'rounded',
                    draw = {
                        columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
                    },
                },
                documentation = {
                    window = { border = 'rounded' },
                },
                list = {
                    selection = { preselect = false, auto_insert = true },
                },
            },

            signature = { enabled = true },
        })

        -- Filetype-specific configurations are handled via the 'enabled' functions
        -- in the provider configurations above

        -- Load snippet collections
        require('luasnip.loaders.from_vscode').lazy_load()
        require('luasnip.loaders.from_vscode').lazy_load({
            paths = { vim.fn.stdpath('config') .. '/snips' }
        })

        -- Extend snippet filetypes
        luasnip.filetype_extend('quarto', { 'markdown' })
        luasnip.filetype_extend('rmarkdown', { 'markdown' })
    end,
}

