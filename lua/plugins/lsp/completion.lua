return {
    -- Specialized completions
    {
        'R-nvim/cmp-r', -- R completions
        config = function()
            require('cmp_r').setup({
                filetypes = { 'r', 'rmd', 'quarto', 'qmd', 'rnoweb', 'rhelp' }, -- ADDED
                doc_width = 58,                                                 -- max. width of documentation window, default: 58
                trigger_characters = { " ", ":", "(", '"', "@", "$" },          -- list of characters that trigger completion, default: {" ", ":", "(", '"', "@", "$"}
                fun_data_1 = { 'select', 'rename', 'mutate', 'filter' },        -- list of functions where data.frame columns are use to autocomplete, default: {'select', 'rename', 'mutate', 'filter'}
                fun_data_2 = { ggplot = { 'aes' }, with = { '*' } }             -- Dictionary with parent function as keys and list of nested functions as values, default: {ggplot = {'aes'}, with = {'*'}}
                -- quarto_intel = "PATH" -- Path to yaml-intelligence-resources.json which is part of quarto application and has all necessary information for completion of valid YAML options in an Quarto document. Default: nil (cmp-r will try to find the file).
            })
        end,
    },
    {
        'saghen/blink.cmp',
        version = '1.*',
        event = 'InsertEnter',
        dependencies = {
            -- Snippet completion
            'L3MON4D3/LuaSnip',             -- the snippet engine
            'rafamadriz/friendly-snippets', -- snippet collections

            {
                'saghen/blink.compat', -- compatibility layer for other completion sources from nvim-cmp
                version = '2.*',
                opt = {}
            },
            'R-nvim/cmp-r',      -- R completions
            'jmbuhr/otter.nvim', -- specialized completion for Quarto and RMarkdown documents
        },
        opts = {
            sources = {
                default = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                per_filetype = {
                    r   = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                    rmd = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                    qmd = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                },
                providers = {
                    cmp_r = { name = 'cmp_r', module = 'blink.compat.source' },
                },
            }
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


                completion = {
                    trigger = {
                        show_on_trigger_character = true,
                    },
                    menu = {
                        border = 'rounded',
                        draw = {
                            columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
                        },
                    },
                    documentation = {
                        window = { border = 'rounded' },
                        auto_show = true,
                        auto_show_delay_ms = 0,
                    },
                    list = {
                        selection = { preselect = false, auto_insert = true },
                    },
                },

                signature = {
                    enabled = true,
                    trigger = {
                        -- Show the signature help automatically
                        enabled = true,
                        -- Show the signature help window after typing any of alphanumerics, `-` or `_`
                        show_on_keyword = false,
                        blocked_trigger_characters = {},
                        blocked_retrigger_characters = {},
                        -- Show the signature help window after typing a trigger character
                        show_on_trigger_character = false,
                        -- Show the signature help window when entering insert mode
                        show_on_insert = false,
                        -- Show the signature help window when the cursor comes after a trigger character when entering insert mode
                        show_on_insert_on_trigger_character = true,
                    },
                    window = {
                        min_width = 1,
                        max_width = 100,
                        max_height = 10,
                        border = nil, -- Defaults to `vim.o.winborder` on nvim 0.11+ or 'padded' when not defined/<=0.10
                        winblend = 0,
                        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
                        -- Which directions to show the window,
                        -- falling back to the next direction when there's not enough space,
                        -- or another window is in the way
                        direction_priority = { 'n', 's' },
                        -- Can accept a function if you need more control
                        -- direction_priority = function()
                        --   if condition then return { 'n', 's' } end
                        --   return { 's', 'n' }
                        -- end,

                        -- Disable if you run into performance issues
                        treesitter_highlighting = true,
                        show_documentation = false,
                    },
                }

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
}
