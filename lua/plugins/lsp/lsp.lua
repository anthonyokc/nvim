return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "j-hui/fidget.nvim",
    },

    config = function()
        -- Extensible UI notifications for LSP progress messages
        require("fidget").setup({})

        -- Package manager for LSP servers
        require("mason").setup()

        -- Needed for completion to work with LSP servers
        local cmp_lsp = require("cmp_nvim_lsp")
        -- Extend the default capabilities with the LSP capabilities
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())
        -- Define server configurations
        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "Lua 5.1" },
                        diagnostics = {
                            globals = { "vim", "it", "describe", "before_each", "after_each" },
                        }
                    }
                }
            },
            -- Define other servers here with their configs
        }

        -- Install and configure LSP servers
        require("mason-lspconfig").setup({
            ensure_installed = vim.tbl_keys(servers),
            automatic_enable = true,
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup(
                        vim.tbl_deep_extend("force",
                            { capabilities = capabilities },
                            servers[server_name] or {}
                        )
                    )
                end,

                ["harper_ls"] = function()
                    require("lspconfig").harper_ls.setup({
                        settings = {
                            linters = {
                                spell_check = false,
                                sentence_capitalization = false,
                            }
                        }
                    })
                end,
            }
        })

        -- Configure diagnostics
        vim.diagnostic.config({
            virtual_text = true,
            float = {
                source = true
            },
        })
    end,
}
