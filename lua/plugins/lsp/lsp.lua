-- LSP Configuration for Neovim
-- 1. Mason: Package manager for LSP servers, DAP servers, linters, and formatters
-- 2. Mason LSP Config: Bridge between Mason and nvim-lspconfig
-- 3. nvim-lspconfig: Provides sensible default configurations for LSP servers
-- 4. nvim-navic: A simple statusline/winbar component that uses LSP to show your current code context
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
                "html-lsp",                        -- HTML Language Server
                "htmx-lsp",                        -- HTMX Language Server
                "jsonlsp",                         -- JSON Language Server
                "lua-language-server",             -- Lua Language Server
                -- "ltex-ls", true                     -- LTeX for text, markdown, latex, restructuredtext
                "nil",                             -- Nix Language Server
                "postgrest-language-server",       -- Postgres Language Server
                "r_language_server",               -- R Language Server
                "rust-analyzer",                   -- Rust Analyzer for Rust
                "terraform-ls",                    -- Terraform Language Server
                "tofu-ls",                         -- OpenTofu Language Server
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
                "pgformatter",    -- PGFormatter for SQL formatting
                "Nixfmt",         -- NixFmt for Nix formatting
                "htmlbeautifier", -- HTML Beautifier for HTML formatting
                "fixjson",        -- FixJSON for JSON formatting
                "gci",            -- GCI, a tool that control golang package import order and make it always deterministic.
                "jq",             -- JQ for JSON processing
                -- "tex-fmt", -- Tex FMT for LaTeX formatting
                "usort",          -- Usort for Python sorting imports

                -- Other tools
                "harper_ls", -- Harper Language Server; grammar and style checker
            },
        }
    },

    -- 2. Mason LSP Config: Bridge between Mason and nvim-lspconfig
    -- Maps Mason package names to nvim-lspconfig server names
    -- Can automatically installs LSP servers installed with Mason
    -- Can auto enable LSP servers with nvim-lspconfig
    -- Can automatically set up servers with default configurations
    {
        "mason-org/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = { automatic_enable = true }, -- default, but kept explicit
    },

    -- 3. LSP Configurations: Provides sensible default configurations for LSP servers
    -- Optionally, you can add server-specific configurations
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre" },
        dependencies = { "saghen/blink.cmp" },
        init = function()
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
                -- Re-enable diagnostics for lua_ls (deferred until server is
                -- ready to avoid false positives) This prevents diagnostic
                -- errors from showing before the Lua language server has fully initialized
                -- and attached to the buffer, avoiding false positives or
                -- confusing error messages during startup
                if client.name == "lua_ls" and vim.bo[bufnr].filetype == "lua" then
                    vim.diagnostic.enable(true, { bufnr = bufnr })
                end
            end

            -- Apply nvim-navic to servers with documentSymbol capability,
            -- and set the on_attach function for all servers
            vim.lsp.config("*", {
                capabilities = capabilities,
                on_attach = on_attach,
            })
            -- End of global LSP configurations ##############################


            -- Configure LSP servers with specific settings
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" }, -- Use LuaJIT runtime
                        diagnostics = {
                            -- Get LSP to recognize the globals like 'vim'
                            globals = { "vim", "it", "describe", "before_each", "after_each" },
                        },
                    }
                }
            })
            vim.lsp.config("r_language_server", {
                settings = {
                    r = {
                        lsp = {
                            diagnostics = false, -- Disable R LSP diagnostics to avoid conflicts with other linters
                        },
                    },
                },
            })
            vim.lsp.config("harper_ls", {
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

    -- 4. nvim-navic: A simple statusline/winbar component that uses LSP to show your current code context
    -- Requires LSP servers to support the 'textDocument/documentSymbol' capability
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig"
    }

}
