return {
    -- 1. Mason: Package‑manager for LSP servers, DAP servers, linters, and formatters.
    -- Does not handle configurations.
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                -- LSP servers
                "bacon_ls",                        -- Bacon Language Server for Rust
                "bash-language-server",            -- Bash Language Server
                "basedpyright",                    -- BasedPyright for Python
                "docker_compose_language_service", -- Docker Compose Language Service
                "dockerfile-language-server",      -- Dockerfile Language Server
                "eslint-lsp",                      -- ESLint Language Server for JavaScript and TypeScript
                "gopls",                           -- Go Language Server
                "jsonlsp",                         -- JSON Language Server
                "lua-langeuage-server",            -- Lua Language Server
                "ltex-ls",                         -- LTeX for text, markdown, latex, restructuredtext
                "r_language_server",               -- R Language Server
                "ruff",                            -- Ruff for Python
                "rust-analyzer",                   -- Rust Analyzer for Rust
                "terraform-ls",                    -- Terraform Language Server
                "texlab",                          -- TexLab for LaTeX
                "tflint",                          -- TFLint for Terraform
                "typescript-language-server",      -- TypeScript Language Server
                "vale-ls",                         -- Vale Language Server for text and markdown

                -- DAP servers
                "bash-debug-adapter", -- Bash Debug Adapter
                "codelldb",           -- CodeLLDB for debugging C, C++, Rust, Zig
                "debugpy",            -- DebugPy for Python debugging

                -- Linters
                "bacon",       -- Bacon for Rust; a linter and formatter
                "hadolint",    -- Hadolint for Dockerfiles
                "ruff",        -- Ruff for Python linting and formatting
                "selene",      -- Selene for Lua and Luau linting
                "shellharden", -- ShellHarden for Bash linting
                "shellcheck",  -- ShellCheck for Bash linting
                "snyk",        -- Snyk for security scanning in various languages
                "tflint",      -- TFLint for Terraform linting
                "trivy",       -- Trivy for security scanning in various languages
                "vale",        -- Vale for text and markdown linting
                "vulture",     -- Vulture for Python dead code detection

                -- Formatters
                "fixjson", -- FixJSON for JSON formatting
                "gci",     -- GCI, a tool that control golang package import order and make it always deterministic.
                "jq",      -- JQ for JSON processing
                "stylua",  -- Stylua for Lua and Luau formatting
                "tex-fmt", -- Tex FMT for LaTeX formatting
                "usort",   -- Usort for Python sorting imports

                -- Other tools
                "harper_ls", -- Harper Language Server; grammar and style checker
            },
        }
    },

    -- 2. Mason LSP Config: Bridge between Mason and nvim-lspconfig
    -- Automatically installs LSP servers installed with Mason
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = { automatic_enable = true }, -- default, but kept explicit
    },

    -- 3. LSP Configurations: Provides sensible default configurations for LSP servers
    -- Optionally, you can add server-specific configurations
    {
        "neomvim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        init = function()
            -- advertise completion capabilities to *every* server
            vim.lsp.config("*", {
                capabilities = require("cmp_nvim_lsp").default_capabilities() -- :contentReference[oaicite:1]{index=1}
            })

            -- Configure LSP servers with specific settings
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = {
                            globals = { "vim", "it", "describe", "before_each", "after_each" },
                        }
                    }
                }
            })
            vim.lsp.config("harper_ls", {
                settings = {
                    ["harper-ls"] = {
                        linters = {
                            SentenceCapitalization = false,
                            SpellCheck             = false,
                        },
                    },
                },
            })

            -- Configure diagnostics
            vim.diagnostic.config({
                virtual_lines = true,
                -- virtual_text = true,
                -- float = {
                --     source = true
                -- },
            })
        end,
    },

    -- 4. Fidget: UI notifications for LSP progress messages
    -- Provides a nice UI for LSP progress messages
    {
        "j-hui/fidget.nvim",
        opts = {},
        config = function()
            require("fidget").setup({})
        end,
    },

    -- 5. cmp-nvim-lsp: LSP completion source for the nvim-cmp completion engine
    -- Provides LSP completion capabilities to nvim-cmp
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = { "hrsh7th/nvim-cmp" },
    },

    -- 6. LazyDev: A lazy loaded plugin for Lua development
    -- Provides lazy loading capabilities for Lua development
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
