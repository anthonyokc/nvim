-- LSP Configuration for Neovim
-- 1. Mason: Package manager for LSP servers, DAP servers, linters, and formatters
-- 2. Mason LSP Config: Bridge between Mason and nvim-lspconfig
-- 3. nvim-lspconfig: Provides sensible default configurations for LSP servers
-- 4. cmp-nvim-lsp: LSP completion source for the nvim-cmp completion engine
-- 5. fidget.nvim: UI notifications for LSP progress messages
-- 6. LazyDev: A lazy loaded plugin for Lua development
return {
  -- 1. Mason: Package‑manager for LSP servers, DAP servers, linters, and formatters.
  -- Does not handle configurations.
  {
    "mason-org/mason.nvim",
    opts = {
      -- Ensure that Mason is installed with these LSPs, DAPs, linters, and formatters
      -- Use :Mason to search for available packages
      -- Adding them manually is not advised to ensure a declarative, reproducible configuration
      ensure_installed = {
        -- LSP servers
        "bacon_ls",                                -- Bacon Language Server for Rust
        "bash-language-server",                    -- Bash Language Server
        "basedpyright",                            -- BasedPyright for Python
        "checkmake",                               -- CheckMake for Makefile linting
        "clangd",                                  -- Clangd for C and C++
        "clang-format",                            -- Clang Format for C and C++
        "cmake-language-server",                   -- CMake Language Server
        "cmakelang",                               -- CMakeLang for CMake formatting
        "docker_compose_language_service",         -- Docker Compose Language Service
        "dockerfile-language-server",              -- Dockerfile Language Server
        "eslint-lsp",                              -- ESLint Language Server for JavaScript and TypeScript
        "gopls",                                   -- Go Language Server
        "jsonlsp",                                 -- JSON Language Server
        "lua-langeuage-server",                    -- Lua Language Server
        -- "ltex-ls",                      -- LTeX for text, markdown, latex, restructuredtext
        "nil",                                     -- Nix Language Server
        "r_language_server",                       -- R Language Server
        "ruff",                                    -- Ruff for Python
        "rust-analyzer",                           -- Rust Analyzer for Rust
        "terraform-ls",                            -- Terraform Language Server
        "texlab",                                  -- TexLab for LaTeX
        "tflint",                                  -- TFLint for Terraform
        "typescript-language-server",              -- TypeScript Language Server
        "vale-ls",                                 -- Vale Language Server for text and markdown

        -- DAP servers
        "bash-debug-adapter",         -- Bash Debug Adapter
        "codelldb",                   -- CodeLLDB for debugging C, C++, Rust, Zig
        "debugpy",                    -- DebugPy for Python debugging
        "go-debug-adapter",           -- Go Debug Adapter
        "js-debug-adapter",           -- JS Debug Adapter for JavaScript and TypeScript
        "netcoredbg",                 -- NetCoreDbg for .NET debugging
        "bash-debug-adapter",         -- Bash Debug Adapter
        "codelldb",                   -- CodeLLDB for debugging C, C++, Rust, Zig
        "debugpy",                    -- DebugPy for Python debugging

        -- Linters
        "bacon",               -- Bacon for Rust; a linter and formatter
        "hadolint",            -- Hadolint for Dockerfiles
        "ruff",                -- Ruff for Python linting and formatting
        "selene",              -- Selene for Lua and Luau linting
        "shellharden",         -- ShellHarden for Bash linting
        "shellcheck",          -- ShellCheck for Bash linting
        "snyk",                -- Snyk for security scanning in various languages
        "tflint",              -- TFLint for Terraform linting
        "trivy",               -- Trivy for security scanning in various languages
        "vale",                -- Vale for text and markdown linting
        "vulture",             -- Vulture for Python dead code detection

        -- Formatters
        "Nixfmt",          -- NixFmt for Nix formatting
        "fixjson",         -- FixJSON for JSON formatting
        "gci",             -- GCI, a tool that control golang package import order and make it always deterministic.
        "jq",              -- JQ for JSON processing
        "stylua",          -- Stylua for Lua and Luau formatting
        "tex-fmt",         -- Tex FMT for LaTeX formatting
        "usort",           -- Usort for Python sorting imports

        -- Other tools
        "harper_ls",         -- Harper Language Server; grammar and style checker
      },
    }
  },

  -- 2. Mason LSP Config: Bridge between Mason and nvim-lspconfig
  -- Automatically installs LSP servers installed with Mason
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = { automatic_enable = true },     -- default, but kept explicit
  },

  -- 3. LSP Configurations: Provides sensible default configurations for LSP servers
  -- Optionally, you can add server-specific configurations
  {
    "neomvim/nvim-lspconfig",
    url = "git@github.com:neovim/nvim-lspconfig.git",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "saghen/blink.cmp" },
    init = function()
      -- advertise completion capabilities ONCE to *every* server
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities()
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
              -- Disablejavascript linter
              SentenceCapitalization = false,
              SpellCheck             = false,
            },
          },
        },
      })


      -- Configure diagnostics
      vim.diagnostic.config({
        -- virtual_lines = true,
        -- virtual_text = true,
        -- float = {
        --     source = true
        -- },
      })
    end,
  },

  -- 4. cmp-nvim-lsp: LSP completion source for the nvim-cmp completion engine
  -- Provides LSP completion capabilities to nvim-cmp
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = { "hrsh7th/nvim-cmp" },
  },

  -- 5. Fidget: UI notifications for LSP progress messages
  -- Provides a nice UI for LSP progress messages
  {
    "j-hui/fidget.nvim",
    opts = {},
    config = function()
      require("fidget").setup({})
    end,
  },

  -- 6. LazyDev: A lazy loaded plugin for Lua development
  -- Provides lazy loading capabilities for Lua development
  {
    "folke/lazydev.nvim",
    ft = "lua",     -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
