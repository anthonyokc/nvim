local helpers = require("config.languages.r.helpers")
local folds = require("config.languages.r.folds")
local object_browser = require("config.languages.r.object_browser")

return {
    "R-nvim/R.nvim",
    lazy = false,
    ft = { 'r', 'rmd', 'qmd', 'quarto', 'rnoweb', 'rhelp' },
    config = function()
        -- Create a table with the options to be passed to setup()
        local setup_options = {
            R_args = { "--quiet", "--no-save" },
            hook = {
                -- This function will be called at the FileType event
                -- of files supported by R.nvim. This is an
                -- opportunity to create mappings local to buffers.
                on_filetype = function()
                    -- Clear mappings that start with comma
                    helpers.clear_prefix_mappings(",")

                    -- Create user command for CSV to object conversion
                    vim.api.nvim_create_user_command(
                        'ReadCsvToObject',
                        helpers.read_csv_to_object,
                        { desc = 'Replace write_csv(obj, here("path")) with read_csv(here("path"))' }
                    )

                    -- Define all keymaps in a table for better organization
                    local keymaps = {
                        -- Built-in R.nvim keymaps (need remap=true for <Plug> mappings)
                        -- Format is: { "mode", "key", "action", "description", { options } }
                        { "i", "<C-k>",          "<Plug>RInsertAssign",       "Insert <-",                       { remap = true } },
                        { "i", "<C-l>",          "<Plug>RInsertPipe",         "Insert |>",                       { remap = true } },
                        { "n", "<Enter>",        "<Plug>RDSendLine",          "Send line to R",                  { remap = true } },
                        { "v", "<Enter>",        "<Plug>RDSendSelection",     "Send selection to R",             { remap = true } },
                        { "n", "<LocalLeader>f", "<Plug>RFormat",             "Format buffer",                   { remap = true } },
                        { "v", "<LocalLeader>f", "<Plug>RFormat",             "Format selection",                { remap = true } },

                        -- Custom paragraph sending
                        { "n", ",",              helpers.send_paragraph_to_r, "Send paragraph to R" },
                        { "v", "<leader>rH",     helpers.read_csv_to_object,  "Write->Read CSV replace (visual)" },

                        -- R actions and helpers
                        { "n", "<leader><CR>",   helpers.r_action(""),        "Run (context)" },
                        { "n", "<leader>rg",     helpers.r_action("glimpse"), "glimpse()" },
                        { "n", "<leader>ri", helpers.r_action(
                            '(function(package){ rlang::as_label(rlang::enexpr(package)) |> renv::install(prompt=FALSE) })'
                        ), "renv install pkg" },

                        -- renv commands
                        { "n", "<leader>rI",  helpers.r_cmd("renv::init()"),                          "renv::init()" },
                        { "n", "<leader>rs",  helpers.r_cmd("renv::status()"),                        "renv::status()" },
                        { "n", "<leader>rR",  helpers.r_cmd("renv::restore()"),                       "renv::restore()" },
                        { "n", "<leader>rS",  helpers.r_cmd("renv::snapshot()"),                      "renv::snapshot()" },

                        -- devtools commands
                        { "n", "<leader>rd",  helpers.r_cmd("devtools::document()"),                  "devtools::document()" },
                        { "n", "<leader>rc",  helpers.r_cmd("devtools::check()"),                     "devtools::check()" },
                        { "n", "<leader>rl",  helpers.r_cmd("devtools::load_all()"),                  "devtools::load_all()" },
                        { "n", "<leader>rt",  helpers.r_cmd("devtools::test_active_file()"),          "devtools::test_active_file()" },
                        { "n", "<leader>rT",  helpers.r_cmd("devtools::test()"),                      "devtools::test()" },
                        { "n", "<leader>rv",  helpers.r_cmd("devtools::test_coverage_active_file()"), "cov (file)" },
                        { "n", "<leader>rV",  helpers.r_cmd("devtools::test_coverage()"),             "cov (all)" },

                        -- usethis commands
                        { "n", "<leader>rut", helpers.r_cmd("usethis::use_test()"),                   "usethis::use_test()" },
                        { "n", "<leader>rup", helpers.r_action(
                            '(function(package){ rlang::as_label(rlang::enexpr(package)) |> usethis::use_package() })'
                        ), "use_package()" },
                        { "n", "<leader>rus", helpers.r_action(
                            '(function(package){ rlang::as_label(rlang::enexpr(package)) |> usethis::use_package(type="Suggests") })'
                        ), 'use_package("Suggests")' },

                        -- View commands
                        { "n", "<leader>V",        helpers.r_action("(function(data){ data |> View() })"), "View object" },
                        { "v", "<leader>V",        helpers.r_action("(function(data){ data |> View() })"), "View selection" },

                        -- Other R commands
                        { "n", "<LocalLeader>hgd", helpers.r_cmd("hgd()"),                                 "hgd()" },
                        { "n", "<leader>tm",       helpers.r_cmd("targets::tar_make()"),                   "targets::tar_make()" },
                        { "n", "<leader>tv",       helpers.r_cmd("targets::tar_visnetwork()"),             "targets::tar_visnetwork()" },
                    }

                    -- Set all keymaps
                    for _, keymap in ipairs(keymaps) do
                        helpers.bufmap(keymap[1], keymap[2], keymap[3], keymap[4], keymap[5])
                    end
                end,
            },

            -- Disable some default commands
            disable_cmds = {
                "RClearConsole",
                "RCustomStart",
                "RSPlot",
                "RSaveClose",
            },

            -- Configuration options
            min_editor_width = 18,

            -- R Console
            rconsole_width = 100,
            OutDec = ".",
            R_app = "radian",
            R_cmd = "R",
            hl_term = true,
            bracketed_paste = true,

            -- PDF Viewer
            open_pdf = "open",
            open_html = "open",

            -- Auto Start
            auto_start = "always",

            -- R Object Browser
            objbr_place = "right",
            objbr_opendf = false,
            objbr_openlist = false,

            -- R Help & Documentation
            nvimpager = "tab",

            -- View a data.frame or matrix
            view_df = {
                open_app = "tmux new-window vd",
            },

            -- Syntax Highlighting
            Rout_more_colors = true,
        }

        -- Call the setup function with the options
        require("r").setup(setup_options)

        -- R output is highlighted with current colorscheme
        vim.g.rout_follow_colorscheme = true

        -- Setup additional modules
        folds.setup()
        object_browser.setup()
    end,
}
