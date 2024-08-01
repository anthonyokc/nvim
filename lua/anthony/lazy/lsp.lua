return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        'hrsh7th/cmp-nvim-lsp-signature-help',
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        'hrsh7th/cmp-calc',
        'hrsh7th/cmp-emoji',
        'jmbuhr/otter.nvim',
        'jmbuhr/cmp-pandoc-references',
        'kdheepak/cmp-latex-symbols',
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        'onsails/lspkind-nvim',
        "j-hui/fidget.nvim",

    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local lspkind = require 'lspkind'
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer"
                --'r_language_server'
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup {
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                --['<Tab>'] = cmp.mapping.confirm({ select = true }),
                ['<C-y>'] = cmp.mapping.complete({ select = true }),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
            }),

            ---@diagnostic disable-next-line: missing-fields
            formatting = {
                format = lspkind.cmp_format {
                    mode = 'symbol',
                    menu = {
                        otter = '[🦦]',
                        nvim_lsp = '',
                        vsnip = '',
                        cmp_zotcite = 'z',
                        cmp_r = 'R',
                        luasnip = '[snip]',
                        buffer = '[buf]',
                        path = '[path]',
                        spell = '[spell]',
                        pandoc_references = '[ref]',
                        tags = '[tag]',
                        treesitter = '[TS]',
                        calc = '[calc]',
                        latex_symbols = '[tex]',
                        emoji = '[emoji]',
                    },
                },
            },
            sources = {
                { name = 'cmp_r' }, -- R completion
                { name = 'otter' }, -- for code chunks in quarto
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'pandoc_references' },
                { name = 'buffer',                 keyword_length = 5, max_item_count = 3 },
                { name = 'spell' },
                { name = 'treesitter',             keyword_length = 5, max_item_count = 3 },
                { name = 'calc' },
                { name = 'latex_symbols' },
                { name = 'emoji' },
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
        }
    end,
}
