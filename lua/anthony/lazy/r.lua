return {
    {
        "R-nvim/R.nvim",
        ft = { 'r', 'rmd', 'qmd', 'rnoweb', 'rhelp' },
        config = function()
            -- Create a table with the options to be passed to setup()
            local setup_options = {
                R_args = { "--quiet", "--no-save" },
                hook = {
                    on_filetype = function()
                        -- This function will be called at the FileType event
                        -- of files supported by R.nvim. This is an
                        -- opportunity to create mappings local to buffers.
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>r", ":call StartR('R')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "i", "<leader>r", "<Esc>:call StartR('R')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<leader>r", "<Esc>:call StartR('R')<CR>", {})

                        -- Clear existing mappings for the comma key in normal and visual modes
                        -- Function to delete key mappings for a specific mode and prefix
                        local function clear_mappings(mode, prefix)
                            local mappings = vim.api.nvim_get_keymap(mode)
                            for _, mapping in pairs(mappings) do
                                if vim.startswith(mapping.lhs, prefix) then
                                    vim.api.nvim_del_keymap(mode, mapping.lhs)
                                end
                            end
                        end
                        -- Clear normal mode mappings that start with a comma
                        clear_mappings('n', ',')
                        -- Clear insert mode mappings that start with a comma
                        clear_mappings('i', ',')
                        -- Clear visual mode mappings that start with a comma
                        clear_mappings('v', ',')
                        -- Clear command-line mode mappings that start with a comma
                        clear_mappings('c', ',')

                        vim.api.nvim_buf_set_keymap(0, "n", ",", "<Plug>RDSendLine", {})
                        vim.api.nvim_buf_set_keymap(0, "v", ",", "<Plug>RDSendSelection", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>f", "<Plug>RFormat", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<LocalLeader>f", "<Plug>RFormat", {})
                        -- vim.api.nvim_buf_set_keymap(0, "v", ",e", "<Plug>RESendSelection", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RDSendSelection", {})

                        -- Custom Actions
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader><Enter>",
                            "<Cmd>lua require('r.run').action('')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>V",
                            "<Cmd>lua require('r.send').cmd('hgd()')<CR>", {})
                    end
                },
                min_editor_width = 80,
                disable_cmds = {
                    "RClearConsole",
                    "RCustomStart",
                    "RSPlot",
                    "RSaveClose",
                },

                -- R Console
                rconsole_width = 100,
                OutDec = ".",

                -- Auto Start
                auto_start = "always",
                objbr_auto_start = true,

                -- R Object Browser
                objbr_place = "console,below", -- place below the R console
                objbr_opendf = false,

                -- R Help & Documentation
                nvimpager = "tab", -- use vertical split for help pages

                -- Built-in Key Maps,
                assignment_keymap = "<C-k>",
                pipe_keymap = "<C-l>",

                -- View a data.frame or matrix, uses <LocalLeader>rv,
                csv_app = "tmux new-window vd",

                -- Syntax Highlighting,
                Rout_more_colors = true, -- R commands in R output, .Rout files, are highlighted
            }
            -- Call the setup function with the options
            require("r").setup(setup_options)

            -- R output is highlighted with current colorscheme
            vim.g.rout_follow_colorscheme = true

            -- Indentation
            vim.opt.tabstop = 2
            vim.opt.softtabstop = 2
            vim.opt.shiftwidth = 2
        end
    },
    {
        "R-nvim/cmp-r",
        opts = {
            filetypes = { 'r', 'rmd', 'qmd', 'rnoweb', 'rhelp' },    -- default: {"r", "rmd", "qmd", "rnoweb", "rhelp"}
            doc_width = 58,                                          -- max. width of documentation window, default: 58
            trigger_characters = { " ", ":", "(", '"', "@", "$" },   -- list of characters that trigger completion, default: {" ", ":", "(", '"', "@", "$"}
            fun_data_1 = { 'select', 'rename', 'mutate', 'filter' }, -- list of functions where data.frame columns are use to autocomplete, default: {'select', 'rename', 'mutate', 'filter'}
            fun_data_2 = { ggplot = { 'aes' }, with = { '*' } }      -- Dictionary with parent function as keys and list of nested functions as values, default: {ggplot = {'aes'}, with = {'*'}}
            -- quarto_intel = "PATH" -- Path to yaml-intelligence-resources.json which is part of quarto application and has all necessary information for completion of valid YAML options in an Quarto document. Default: nil (cmp-r will try to find the file).
        }
    }
}
