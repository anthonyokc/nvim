return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            -- A list of parser names, or "all"
            ensure_installed = {
                "r",
                "python",
                "markdown",
                "markdown_inline",
                "rnoweb",
                "vimdoc",
                "javascript",
                "typescript",
                "c",
                "lua",
                "rust",
                "jsdoc",
                "bash",
                'julia',
                'yaml',
                'query',
                'vim',
                'vimdoc',
                'latex', -- requires tree-sitter-cli (installed automatically via Mason)
                'html',
                'css',
                'dot',
                'mermaid',
                'norg',
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
            auto_install = true,

            indent = {
                enable = true
            },

            highlight = {
                -- `false` will disable the whole extension
                enable = true,

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = { "markdown" },
            },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = 'gnn',
                    node_incremental = 'grn',
                    scope_incremental = 'grc',
                    node_decremental = 'grm',
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']]'] = '@class.inner',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[['] = '@class.inner',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer',
                    },
                },
            }

        })

        local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        treesitter_parser_config.templ = {
            install_info = {
                url = "https://github.com/vrischmann/tree-sitter-templ.git",
                files = { "src/parser.c", "src/scanner.c" },
                branch = "master",
            },
        }

        vim.treesitter.language.register("templ", "templ")

        local ts_utils = require 'nvim-treesitter.ts_utils'

        local function reformat_hovered_function()
            local bufnr = vim.api.nvim_get_current_buf()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local root = ts_utils.get_root_for_position(row - 1, col - 1, bufnr)
            if not root then return end

            local node = ts_utils.get_node_at_cursor()
            if not node then return end

            while node do
                if node:type() == 'function_call' then
                    local start_row, start_col, end_row, end_col = node:range()
                    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
                    local text = table.concat(lines, "\n")
                    local func_name = text:match("^%s*(%w+)%s*%(")

                    if func_name then
                        local args = text:match("%((.*)%)")
                        if args then
                            local formatted_args = "(\n    " .. args:gsub(",%s*", ",\n    ") .. "\n  )"
                            local new_text = func_name .. formatted_args
                            vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, { new_text })
                        end
                    end
                    break
                end
                node = node:parent()
            end
        end

        vim.api.nvim_set_keymap('n', '<leader>rf', '<cmd>lua reformat_hovered_function()<CR>',
            { noremap = true, silent = true })
    end
}
