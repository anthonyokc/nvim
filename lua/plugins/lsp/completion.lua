return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        -- LSP completion
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lsp-signature-help',

        -- Snippet completion
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',

        -- Path and buffer completion
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',

        -- Other completion sources
        'hrsh7th/cmp-calc',
        'hrsh7th/cmp-emoji',
        'hrsh7th/cmp-cmdline',
        'f3fora/cmp-spell',
        'ray-x/cmp-treesitter',

        -- Specialized completions
        'kdheepak/cmp-latex-symbols',
        'jmbuhr/cmp-pandoc-references',
        'jmbuhr/otter.nvim',

        -- UI
        'onsails/lspkind-nvim',
    },
    config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local lspkind = require('lspkind')

        local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and
                vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
        end

        -- Common completion settings
        local common_config = {
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            completion = { completeopt = 'menu,menuone,noinsert' },
            mapping = {
                ['<C-f>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
                ['<C-n>'] = cmp.mapping(function(fallback)
                    if luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<C-p>'] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<C-y>'] = cmp.mapping.complete({ select = true }),
                ['<Tab>'] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                },
            },
            formatting = {
                format = lspkind.cmp_format {
                    mode = 'symbol',
                    symbol_map = { Copilot = "" },
                    max_width = 50,
                    menu = {
                        otter = '[🦦]',
                        Copilot = "",
                        nvim_lsp = '',
                        luasnip = '[snip]',
                        buffer = '[buf]',
                        path = '[path]',
                        spell = '[spell]',
                        pandoc_references = '[ref]',
                        treesitter = '[TS]',
                        calc = '[calc]',
                        latex_symbols = '[tex]',
                        emoji = '[emoji]',
                    },
                },
            },
        }

        -- Default sources with priority
        local default_sources = {
            -- Primary sources (always active)
            { name = 'nvim_lsp',                priority = 10 },
            { name = 'luasnip',                 priority = 8 },
            { name = 'path',                    priority = 7 },
            { name = 'nvim_lsp_signature_help', priority = 6 },

            -- Secondary sources (with constraints)
            { name = 'buffer',                  max_item_count = 3, keyword_length = 5, priority = 3 },
            { name = 'spell',                   priority = 3 },
            { name = 'treesitter',              max_item_count = 3, keyword_length = 5, priority = 2 },

            -- Utility sources
            { name = 'calc',                    priority = 5 },
            { name = 'emoji',                   priority = 4 },
        }

        -- Default setup
        cmp.setup(vim.tbl_extend('force', common_config, {
            sources = default_sources
        }))

        -- Filetype-specific configurations
        cmp.setup.filetype('lua', {
            sources = cmp.config.sources({
                { name = 'nvim_lsp', priority = 10 },
                { name = 'luasnip',  priority = 8 },
                { name = 'path',     priority = 7 },
            }, {
                { name = 'buffer', keyword_length = 3, priority = 3 },
            })
        })

        cmp.setup.filetype({ 'quarto', 'markdown' }, {
            sources = cmp.config.sources({
                { name = 'otter',             priority = 10 },
                { name = 'pandoc_references', priority = 9 },
                { name = 'nvim_lsp',          priority = 8 },
                { name = 'latex_symbols',     priority = 7 },
                { name = 'luasnip',           priority = 6 },
            }, {
                { name = 'buffer', keyword_length = 3, priority = 3 },
            })
        })

        -- Setup for LaTex files
        cmp.setup.filetype({ 'tex', 'latex' }, {
            sources = cmp.config.sources({
                { name = 'nvim_lsp',      priority = 10 },
                { name = 'latex_symbols', priority = 9 },
                { name = 'luasnip',       priority = 8 },
            }, {
                { name = 'buffer', keyword_length = 3, priority = 3 },
            })
        })

        -- Command line completion
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

        -- Load snippets
        require('luasnip.loaders.from_vscode').lazy_load()
        require('luasnip.loaders.from_vscode').lazy_load {
            paths = { vim.fn.stdpath('config') .. '/snips' }
        }

        -- Link file types for snippets
        luasnip.filetype_extend('quarto', { 'markdown' })
        luasnip.filetype_extend('rmarkdown', { 'markdown' })
    end,
}

