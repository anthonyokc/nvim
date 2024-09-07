return {
    {
        "R-nvim/R.nvim",
        ft = { 'r', 'rmd', 'qmd', 'quarto', 'rnoweb', 'rhelp' },
        config = function()
            -- Create a table with the options to be passed to setup()
            local setup_options = {
                R_args = { "--quiet", "--no-save" },
                hook = {
                    on_filetype = function()
                        -- This function will be called at the FileType event
                        -- of files supported by R.nvim. This is an
                        -- opportunity to create mappings local to buffers.

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
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>ri",
                            "<Cmd>lua require('r.run').action('(function(package) { rlang::as_label(rlang::enexpr(package)) |> renv::install(prompt = FALSE) })')<CR>",
                            {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rI",
                            "<Cmd>lua require('r.send').cmd('renv::init()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rs",
                            "<Cmd>lua require('r.send').cmd('renv::status()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rR",
                            "<Cmd>lua require('r.send').cmd('renv::restore()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rS",
                            "<Cmd>lua require('r.send').cmd('renv::snapshot()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rd",
                            "<Cmd>lua require('r.send').cmd('devtools::document()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rc",
                            "<Cmd>lua require('r.send').cmd('devtools::check()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rl",
                            "<Cmd>lua require('r.send').cmd('devtools::load_all()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rt",
                            "<Cmd>lua require('r.send').cmd('devtools::test_active_file()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rT",
                            "<Cmd>lua require('r.send').cmd('devtools::test()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rv",
                            "<Cmd>lua require('r.send').cmd('devtools::test_coverage_active_file()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rV",
                            "<Cmd>lua require('r.send').cmd('devtools::test_coverage()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rut",
                            "<Cmd>lua require('r.send').cmd('usethis::use_test()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rup",
                            "<Cmd>lua require('r.run').action('(function(package) { rlang::as_label(rlang::enexpr(package)) |> usethis::use_package() })')<CR>",
                            {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rus",
                            "<Cmd>lua require('r.run').action('(function(package) { rlang::as_label(rlang::enexpr(package)) |> usethis::use_package(type = \"Suggests\") })')<CR>",
                            {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>V",
                            "<Cmd>lua require('r.send').cmd('hgd()')<CR>", {})
                    end
                },
                disable_cmds = {
                    "RClearConsole",
                    "RCustomStart",
                    "RSPlot",
                    "RSaveClose",
                },

                min_editor_width = 18,
                -- R Console
                rconsole_width = 100,
                OutDec = ".",
                R_app = "radian",
                R_cmd = "R",
                -- RStudio_cmd = "/usr/bin/rstudio",
                hl_term = true,
                bracketed_paste = true,

                -- PDF Viewer
                open_pdf = "open",
                open_html = "open",

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
