return {
    -- Specialized completions
    {
        "R-nvim/cmp-r",
        event = { "BufRead", "BufNewFile" },
        config = function()
            require('cmp_r').setup({
                filetypes = { 'r', 'rmd', 'qmd', 'rnoweb', 'rhelp' },             -- default: {"r", "rmd", "qmd", "rnoweb", "rhelp"}
                doc_width = 58,                                                   -- max. width of documentation window, default: 58
                trigger_characters = { " ", ":", "(", ",", ", ", '"', "@", "$" }, -- list of characters that trigger completion, default: {" ", ":", "(", '"', "@", "$"}
                fun_data_1 = { 'select', 'rename', 'mutate', 'filter' },          -- list of functions where data.frame columns are use to autocomplete, default: {'select', 'rename', 'mutate', 'filter'}
                fun_data_2 = { ggplot = { 'aes' }, with = { '*' } }               -- Dictionary with parent function as keys and list of nested functions as values, default: {ggplot = {'aes'}, with = {'*'}}
                -- quarto_intel = "PATH" -- Path to yaml-intelligence-resources.json which is part of quarto application and has all necessary information for completion of valid YAML options in an Quarto document. Default: nil (cmp-r will try to find the file).
            })
        end,
    },
    {
        'saghen/blink.cmp',
        version = '1.*',
        event = 'InsertEnter',
        dependencies = {
            { 'nvim-mini/mini.nvim', version = false },
            -- Snippet completion
            'L3MON4D3/LuaSnip',             -- the snippet engine
            'rafamadriz/friendly-snippets', -- snippet collections

            {
                'saghen/blink.compat', -- compatibility layer for other completion sources from nvim-cmp
                version = '2.*',
                opt = {}
            },
            'R-nvim/cmp-r',           -- R completions
            'jmbuhr/otter.nvim',      -- specialized completion for Quarto and RMarkdown documents
            "moyiz/blink-emoji.nvim", -- emoji completion
        },
        opts = {},
        config = function()
            local blink = require('blink.cmp')
            local luasnip = require('luasnip')

            blink.setup({
                sources = {
                    default = { 'cmp_r', 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'omni', 'emoji' },
                    per_filetype = {
                        r   = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                        rmd = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                        qmd = { 'cmp_r', 'lsp', 'path', 'snippets', 'buffer' },
                        sql = { 'lsp', 'snippets', 'dadbod', 'buffer',},
                        psql = { 'lsp', 'snippets', 'dadbod', 'buffer',},
                    },
                    providers = {
                        cmp_r = {
                            name = 'cmp_r',
                            module = 'blink.compat.source',
                            -- Boost cmp-r items; cmp-r already sets sortText for args
                            score_offset = 20,
                            -- Nudge cmp-r "function argument" items (sort_text == '0')
                            -- to display with a distinct kind and bias UI sorting
                            transform_items = function(_, items)
                                for _, item in ipairs(items) do
                                    if item.sort_text == '0' then
                                        -- Reclassify as TypeParameter to differentiate from variables
                                        item.kind = 'TypeParameter'
                                    end
                                end
                                return items
                            end,
                        },
                        dadbod = {
                            name = "Dadbod",
                            module = "vim_dadbod_completion.blink",
                            score_offset = 30,
                        },
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            -- make lazydev completions top priority (see `:h blink.cmp`)
                            score_offset = 100,
                        },
                        emoji = {
                            module = "blink-emoji",
                            name = "Emoji",
                            score_offset = 15, -- Tune by preference
                            opts = {
                                insert = true, -- Insert emoji (default) or complete its name
                                ---@type string|table|fun():table
                                trigger = function()
                                    return { ":" }
                                end,
                            },
                        },
                    },
                },
                keymap = {
                    preset = 'default',
                    ['<C-e>'] = { 'show' },
                    ['<C-y>'] = { 'select_and_accept' },
                    ['<Tab>'] = { 'snippet_forward', 'select_and_accept', 'fallback' },
                    ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
                },

                -- Completion menu: the floating window that shows the list of completion items as you type
                completion = {
                    trigger = {
                        show_on_trigger_character = true,
                        show_on_blocked_trigger_characters = { '\n', '\t' }, -- allow space for R completions
                    },
                    menu = {
                        auto_show = true,

                        border = "rounded",
                        draw = {
                            columns = {
                                { "label",     "label_description", gap = 1 },
                                { "kind_icon", "kind",              "source_name", gap = 1 }
                            },
                        },
                    },
                    -- Documentation: the floating window that shows details about the currently selected completion item
                    documentation = {
                        window = { border = 'rounded' },
                        auto_show = true,
                        auto_show_delay_ms = 0,
                    },
                    list = {
                        selection = { preselect = true, auto_insert = true },
                    },
                },

                -- Signature help: the floating window that shows function signatures as you type
                signature = {
                    enabled = true,
                    trigger = {
                        -- Show the signature help automatically
                        enabled = true,
                        -- Show the signature help window after typing any of alphanumerics, `-` or `_`
                        show_on_keyword = false,
                        blocked_trigger_characters = {},
                        blocked_retrigger_characters = {},
                        show_on_trigger_character = true,           -- Show the signature help window after typing a trigger character
                        show_on_insert = true,                      -- Show the signature help window when entering insert mode
                        show_on_insert_on_trigger_character = true, -- Show the signature help window when the cursor comes after a trigger character when entering insert mode
                    },
                    window = {
                        min_width = 1,
                        max_width = 150,
                        max_height = 10,
                        border = "rounded", -- Defaults to `vim.o.winborder` on nvim 0.11+ or 'padded' when not defined/<=0.10
                        winblend = 0,
                        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
                        direction_priority = { 'n', 's' },
                        treesitter_highlighting = true,
                        show_documentation = true,
                    },
                },
                cmdline = {
                    keymap = { preset = 'inherit' },
                    completion = { menu = { auto_show = true } },
                },

            })
            -- For blink.nvim completion menu
            -- Make the completion menu and doc window have a transparent background
            -- so that the colors from the main colorscheme show through
            -- NOTE: Aesthetic - Set up autocmd to apply highlights after colorscheme loads
            local function set_blink_highlights()
                vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "NONE" })       -- menu body
                vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "NONE" }) -- menu border
                vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "NONE" })        -- docs window body
                vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "NONE" })  -- docs window border
            end

            -- Set highlights after colorscheme is loaded and on colorscheme changes
            vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
                group = vim.api.nvim_create_augroup("BlinkCmpHighlights", { clear = true }),
                callback = function()
                    vim.schedule(set_blink_highlights) -- Use vim.schedule to ensure this runs after other highlight groups are set
                end,
                desc = "Set blink.cmp transparent highlights after colorscheme loads/changes"
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
