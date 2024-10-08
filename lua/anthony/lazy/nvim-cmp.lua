return {
    { -- completion
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-calc',
            'hrsh7th/cmp-emoji',
            'saadparwaiz1/cmp_luasnip',
            'f3fora/cmp-spell',
            'ray-x/cmp-treesitter',
            'kdheepak/cmp-latex-symbols',
            'jmbuhr/cmp-pandoc-references',
            'L3MON4D3/LuaSnip',
            'rafamadriz/friendly-snippets',
            'onsails/lspkind-nvim',
            'jmbuhr/otter.nvim',
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            local lspkind = require 'lspkind'

            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
            end

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = 'menu,menuone,noinsert' },
                mapping = {
                    ['<C-f>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),

                    ['<C-n>'] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
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
                    ['<c-y>'] = cmp.mapping.confirm {
                        select = true,
                    },
                    ['<Tab>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    -- ['<Tab>'] = vim.schedule_wrap(function(fallback)
                    --     if cmp.visible() and has_words_before() then
                    --         cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                    --     else
                    --         fallback()
                    --     end
                    -- end),

                    -- Expand completion with tab
                    -- ['<Tab>'] = cmp.mapping(function(fallback)
                    --   if cmp.visible() then
                    --     cmp.select_next_item()
                    --   elseif has_words_before() then
                    --     cmp.complete()
                    --   else
                    --     fallback()
                    --   end
                    -- end, { 'i', 's' }),
                    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
                    --   if cmp.visible() then
                    --     cmp.select_prev_item()
                    --   else
                    --     fallback()
                    --   end
                    -- end, { 'i', 's' }),

                    -- ['<C-l>'] = cmp.mapping(function()
                    --   if luasnip.expand_or_locally_jumpable() then
                    --     luasnip.expand_or_jump()
                    --   end
                    -- end, { 'i', 's' }),
                    -- ['<C-h>'] = cmp.mapping(function()
                    --   if luasnip.locally_jumpable(-1) then
                    --     luasnip.jump(-1)
                    --   end
                    -- end, { 'i', 's' }),
                },
                autocomplete = false,

            }

            -- for friendly snippets
            require('luasnip.loaders.from_vscode').lazy_load()
            -- for custom snippets
            require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snips' } }
            -- link quarto and rmarkdown to markdown snippets
            luasnip.filetype_extend('quarto', { 'markdown' })
            luasnip.filetype_extend('rmarkdown', { 'markdown' })
        end,
    },

}
