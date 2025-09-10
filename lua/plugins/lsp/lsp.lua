-- LSP Configuration for Neovim
-- 1. Mason: Package manager for LSP servers, DAP servers, linters, and formatters
-- 2. Mason LSP Config: Bridge between Mason and nvim-lspconfig
-- 3. nvim-navic: A simple statusline/winbar component that uses LSP to show your current code context
return {
    -- 1. Mason: Package‑manager for LSP servers, DAP servers, linters, and formatters.
    -- Does not handle configurations.
    -- Blink.nvim will automatically install LSP servers installed with Mason
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {
            -- Ensure that Mason is installed with these LSPs, DAPs, linters, and formatters
            -- Use :Mason to search for available packages
            -- Adding them manually is not advised to ensure a declarative, reproducible configuration
            ensure_installed = {
                -- LSP servers
                "bacon_ls",                        -- Bacon Language Server for Rust
                "bash-language-server",            -- Bash Language Server
                "basedpyright",                    -- BasedPyright for Python
                "checkmake",                       -- CheckMake for Makefile linting
                "clangd",                          -- Clangd for C and C++
                "clang-format",                    -- Clang Format for C and C++
                "cmake-language-server",           -- CMake Language Server
                "cmakelang",                       -- CMakeLang for CMake formatting
                "docker_compose_language_service", -- Docker Compose Language Service
                "dockerfile-language-server",      -- Dockerfile Language Server
                "eslint-lsp",                      -- ESLint Language Server for JavaScript and TypeScript
                "gopls",                           -- Go Language Server
                "jsonlsp",                         -- JSON Language Server
                "lua-langeuage-server",            -- Lua Language Server
                -- "ltex-ls", true                     -- LTeX for text, markdown, latex, restructuredtext
                "nil",                             -- Nix Language Server
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
                "go-debug-adapter",   -- Go Debug Adapter
                "js-debug-adapter",   -- JS Debug Adapter for JavaScript and TypeScript
                "netcoredbg",         -- NetCoreDbg for .NET debugging
                -- Linters
                "bacon",              -- Bacon for Rust; a linter and formatter
                "hadolint",           -- Hadolint for Dockerfiles

                "ruff",               -- Ruff for Python linting and formatting
                "selene",             -- Selene for Lua and Luau linting
                "shellharden",        -- ShellHarden for Bash linting
                "shellcheck",         -- ShellCheck for Bash linting
                "snyk",               -- Snyk for security scanning in various languages
                "tflint",             -- TFLint for Terraform linting
                "trivy",              -- Trivy for security scanning in various languages
                "vale",               -- Vale for text and markdown linting
                "vulture",            -- Vulture for Python dead code detection

                -- Formatters
                "Nixfmt",  -- NixFmt for Nix formatting
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

    -- 2. LSP Configurations: Provides sensible default configurations for LSP servers
    -- Optionally, you can add server-specific configurations
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "saghen/blink.cmp" },
        config = function()
            local lspconfig = require("lspconfig") -- Import nvim-lspconfig
            local util = require("lspconfig.util")

            -- Create a global table to hold LSP configurations ##############
            -- This allows sharing configurations across different files
            -- without polluting the global namespace

            -- Advertise completion capabilities ONCE to *every* server
            local capabilities = require("blink.cmp").get_lsp_capabilities() -- Get LSP capabilities from blink.cmp
            vim.lsp.handlers["textDocument/signatureHelp"] = function() end  -- Disable LSP signature help since blink.cmp handles it


            -- This function is called when an LSP server attaches to a buffer
            -- It checks if the server supports document symbols and attaches nvim-navic if so
            -- nvim-navic requires the LSP server to support 'textDocument/documentSymbol'
            local on_attach = function(client, bufnr)
                if client.server_capabilities and client.server_capabilities.documentSymbolProvider then
                    pcall(require("nvim-navic").attach, client, bufnr)
                end
            end

            -- Apply nvim-navic to servers with documentSymbol capability,
            -- and set the on_attach function for all servers
                util.default_config = vim.tbl_deep_extend("force", util.default_config, {
                  capabilities = caps,
                  on_attach = on_attach,
                })
            -- End of global LSP configurations ##############################


            -- Configure LSP servers with specific settings
            lspconfig.lua_ls.setup( {
                settings = {
                    Lua = {
                        format = {
                            enable = true,
                            defaultConfig = {
                                indent_style = "space",
                                indent_size = "4",
                            },
                        },
                        runtime = { version = "LuaJIT" }, -- Use LuaJIT runtime
                        diagnostics = {
                            -- Get LSP to recognize the globals like 'vim'
                            globals = { "vim", "it", "describe", "before_each", "after_each" },
                        },
                    }
                }
            })
            lspconfig.harper_ls.setup( {
                settings = {
                    ["harper-ls"] = {
                        linters = {
                            SentenceCapitalization = false,
                            SpellCheck             = false,
                            LongSentences          = false,
                            Dashes                 = false,
                        },
                    },
                },
            })


            -- Configure diagnostics
            vim.diagnostic.config({
                -- Displays lines pointing to the part of the code with the diagnostic
                virtual_lines = {
                    severity = { min = vim.diagnostic.severity.WARN } -- Only show warnings and errors
                },
                virtual_text = false,                                 -- Displays the diagnostic message inline
                float = {
                    source = true,                                    -- Show the source of the diagnostic in the floating window
                    border = "rounded",                               -- Use rounded borders for the floating window
                },

            })
        end,
    },

    -- 3. nvim-navic: A simple statusline/winbar component that uses LSP to show your current code context
    -- Requires LSP servers to support the 'textDocument/documentSymbol' capability
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig"
    }

}
