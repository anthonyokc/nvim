local helpers = require("config.languages.r.helpers")
local folds = require("config.languages.r.folds")
local object_browser = require("config.languages.r.object_browser")
local object_picker = require("config.languages.r.object_picker")

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
                        { "i", "<C-h>",            "<Plug>RInsertAssign",              "Insert <-",                             { remap = true } },
                        { "i", "<C-l>",            "<Plug>RInsertPipe",                "Insert |>",                             { remap = true } },
                        { "n", "<Enter>",          "<Plug>RDSendLine",                 "Send line to R",                        { remap = true } },
                        { "v", "<Enter>",          "<Plug>RDSendSelection",            "Send selection to R",                   { remap = true } },
                        { "n", "<LocalLeader>f",   "<Plug>RFormat",                    "Format buffer",                         { remap = true } },
                        { "v", "<LocalLeader>f",   "<Plug>RFormat",                    "Format selection",                      { remap = true } },
                        { "n", "<leader>V",        "<Plug>RViewDF",                    "View object",                           { remap = true } },
                        { "v", "<leader>V",        "<Plug>RViewDF",                    "View object",                           { remap = true } },
                        { "v", "<leader>rv",       "<Plug>RViewDF",                    "View object under cursor",              { remap = true } },
                        { "n", "<leader>r<Enter>", "<Plug>RSendChain",                 "Send piped chain up to current cursor", { remap = true } },

                        -- Custom paragraph sending
                        { "n", ",",                helpers.send_paragraph_to_r,        "Send paragraph to R" },
                        { "v", "<leader>rH",       helpers.read_csv_to_object,         "Write->Read CSV replace (visual)" },
                        { "n", "<leader>rG",       helpers.send_chain_glimpse,         "Send pipe chain & glimpse()" },
                        { "n", "<leader>rV",       helpers.send_chain_view,            "Send pipe chain & view()" },


                        -- R actions and helpers
                        { "n", "<leader><CR>",     helpers.r_action(""),               "Run (context)" },
                        { "v", "<leader><CR>",     "<Plug>RDSendSelection",            "Run selection",                        { remap = true } },
                        { "n", "<leader>fo",       object_picker.open_global_env,      "Find R object (.GlobalEnv)" },
                        { "n", "<leader>fl",       object_picker.open_library_objects, "Find R library object" },
                        { "n", "<leader>ra", function()
                            require("config.languages.r").toggle_assignment_current_object()
                        end, "Toggle pipe assignment" },
                        { "n", "<leader>rp", function()
                            require("config.languages.r").toggle_trailing_pipe_current_line()
                        end, "Toggle trailing pipe" },
                        { "n", "<leader>re", function()
                            require("config.languages.r").assign_defaults_current_function()
                        end, "Assign function defaults to Global Environment" },
                        { "n", "<leader>rg", helpers.r_action("dplyr::glimpse"), "glimpse(data)" },
                        { "n", "<leader>rP", helpers.r_action("problems"),       "problems(data)" },
                        { "n", "<leader>ri", helpers.r_action(
                            '(function(package){ rlang::as_label(rlang::enexpr(package)) |> renv::install(prompt=FALSE) })'
                        ), "renv install package" },

                        -- targets commands and actions
                        { "n", "<leader>tm",  helpers.r_action("targets::tar_make"),                  "targets::tar_make(data)" },
                        { "n", "<leader>tM",  helpers.r_cmd("targets::tar_make()"),                   "targets::tar_make()" },
                        { "n", "<leader>tf",  helpers.r_action("tmf"),                                "tmf(data)" },
                        { "n", "<leader>tF",  helpers.r_cmd("tmf"),                                   "tmf()" },
                        { "n", "<leader>tl",  helpers.r_action("targets::tar_load"),                  "tar_load(data)" },
                        { "n", "<leader>tL",  helpers.r_cmd("targets::tar_load_everything()"),        "tar_load_everything()" },
                        { "n", "<leader>tr",  helpers.r_cmd("targets::tar_read()"),                   "targets::tar_read()" },
                        { "n", "<leader>tv",  helpers.r_cmd("targets::tar_visnetwork()"),             "targets::tar_visnetwork()" },

                        -- renv commands
                        { "n", "<leader>rI",  helpers.r_cmd("renv::init()"),                          "renv::init()" },
                        { "n", "<leader>rs",  helpers.r_cmd("renv::status()"),                        "renv::status()" },
                        { "n", "<leader>rR",  helpers.r_cmd("renv::restore()"),                       "renv::restore()" },
                        { "n", "<leader>rS",  helpers.r_cmd("renv::snapshot()"),                      "renv::snapshot()" },

                        -- devtools commands
                        { "n", "<leader>rd",  helpers.r_cmd("devtools::document()"),                  "devtools::document()" },
                        { "n", "<leader>rC",  helpers.r_cmd("devtools::check()"),                     "devtools::check()" },
                        { "n", "<leader>rl",  helpers.r_cmd("devtools::load_all()"),                  "devtools::load_all()" },
                        { "n", "<leader>rt",  helpers.r_cmd("devtools::test_active_file()"),          "devtools::test_active_file()" },
                        { "n", "<leader>rT",  helpers.r_cmd("devtools::test()"),                      "devtools::test()" },
                        { "n", "<leader>rk",  helpers.r_cmd("devtools::test_coverage_active_file()"), "cov (file)" },
                        { "n", "<leader>rK",  helpers.r_cmd("devtools::test_coverage()"),             "cov (all)" },

                        -- usethis commands
                        { "n", "<leader>rut", helpers.r_cmd("usethis::use_test()"),                   "usethis::use_test()" },
                        { "n", "<leader>rup", helpers.r_action(
                            '(function(package){ rlang::as_label(rlang::enexpr(package)) |> usethis::use_package() })'
                        ), "use_package()" },
                        { "n", "<leader>rus", helpers.r_action(
                            '(function(package){ rlang::as_label(rlang::enexpr(package)) |> usethis::use_package(type="Suggests") })'
                        ), 'use_package("Suggests")' },

                        -- Other R commands
                        { "n", "<LocalLeader>hgd", helpers.r_cmd("hgd()"), "hgd()" },
                    }

                    -- Set all keymaps
                    for _, keymap in ipairs(keymaps) do
                        helpers.bufmap(keymap[1], keymap[2], keymap[3], keymap[4], keymap[5])
                    end

                    if vim.tbl_contains({ 'quarto', 'qmd' }, vim.bo.filetype) then
                        vim.schedule(function()
                            if vim.api.nvim_buf_is_valid(0) then
                                helpers.bufmap('n', '<Enter>', helpers.send_quarto_line_to_r, 'Send line to R')
                                helpers.bufmap('v', '<Enter>', helpers.send_quarto_selection_to_r, 'Send selection to R')
                                helpers.bufmap('v', '<leader><CR>', helpers.send_quarto_selection_to_r, 'Run selection')
                            end
                        end)
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
            min_editor_width = 18, -- Minimum width for R console split

            -- R Console
            rconsole_width = 100,
            OutDec = ".",
            R_app = "radian-ctrlg",
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

            -- TODO: Add clear console command
            -- clear_console = "<leader>rc",
            -- TODO: Insert Assing & Pipe
            -- clear_console = "<leader>rc",

            -- R Help & Documentation
            nvimpager = "tab",

            -- View a data.frame or matrix
            view_df = {
                -- open_app = "terminal:vd"
                open_app = "tmux new-window vd", -- Command to open the data viewer app, use "terminal:APP" to open in a terminal
                how = "tabnew",                  -- How to display the data if doing it within Neovim
                n_lines = 0,                     -- Number of lines to save in the CSV (0 for all lines).
                --csv_sep = "\t",  -- Field separator to be used when saving the CSV. Defaults to comma (,)
                save_fun =
                "function(obj, obj_name) {f <- paste0(obj_name, '.parquet'); arrow::write_parquet(obj, f) ; f}",
                -- save_fun = "", -- R function to save the data.frame in a CSV file. Default uses base::write.table()
                -- save_fun =
                -- "function(obj, obj_name) {f <- paste0('/tmp/', obj_name, '.csv'); data.table::fwrite(obj, f, sep = ',') ; f}",
                -- open_fun = "", -- R function to open the data.frame directly (no conversion to CSV needed)


            },

            -- Syntax Highlighting
            Rout_more_colors = true,
        }

        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "term://*radian-ctrlg*",
            callback = function(args)
                vim.keymap.set("t", "<C-c>", [[<C-\><C-n>]], { buffer = args.buf, desc = "Exit R terminal mode" })
                vim.keymap.set("t", "<C-g>", function()
                    vim.fn.chansend(vim.b[args.buf].terminal_job_id, "\007")
                end, { buffer = args.buf, desc = "Interrupt R" })
            end,
        })

        -- Call the setup function with the options
        require("r").setup(setup_options)

        -- R output is highlighted with current colorscheme
        vim.g.rout_follow_colorscheme = true

        -- Setup additional modules
        folds.setup()
        object_browser.setup()
    end,
}