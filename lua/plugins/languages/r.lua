return {
    {
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
                        -- Function to delete key mappings for a specific mode and prefix
                        local function clear_mappings(mode, prefix)
                            local mappings = vim.api.nvim_get_keymap(mode)
                            for _, mapping in pairs(mappings) do
                                if vim.startswith(mapping.lhs, prefix) then
                                    vim.api.nvim_del_keymap(mode, mapping.lhs)
                                end
                            end
                        end
                        local function read_csv_to_object()
                            local start_line, end_line = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]
                            local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

                            for _, line in ipairs(lines) do
                                local object_name, file_path = line:match("write_csv%(([%w_]+),%s*here%(\"(.+)\"%)%)")
                                if object_name and file_path then
                                    local new_line = string.format("%s <- read_csv(here(\"%s\"))", object_name, file_path)
                                    vim.api.nvim_buf_set_lines(0, start_line - 1, start_line, false, { new_line })
                                end
                                start_line = start_line + 1
                            end
                        end

                        vim.api.nvim_create_user_command('ReadCsvToObject', read_csv_to_object, {})

                        -- KEYMAPS & COMMANDS #################################

                        -- Clear normal mode mappings that start with a comma
                        clear_mappings('n', ',')
                        -- Clear insert mode mappings that start with a comma
                        clear_mappings('i', ',')
                        -- Clear visual mode mappings that start with a comma
                        clear_mappings('v', ',')
                        -- Clear command-line mode mappings that start with a comma
                        clear_mappings('c', ',')


                        -- Built-in Key Maps,
                        vim.api.nvim_buf_set_keymap(0, "i", "<C-k>", "<Plug>RInsertAssign", {})
                        vim.api.nvim_buf_set_keymap(0, "i", "<C-l>", "<Plug>RInsertPipe", {})
                        vim.api.nvim_buf_set_keymap(0, "n", ",", "<Plug>RDSendLine", {})
                        vim.api.nvim_buf_set_keymap(0, "v", ",", "<Plug>RDSendSelection", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>f", "<Plug>RFormat", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<LocalLeader>f", "<Plug>RFormat", {})
                        -- vim.api.nvim_buf_set_keymap(0, "v", ",e", "<Plug>RESendSelection", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RDSendSelection", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<leader>rH", "<CMD>ReadCsvToObject<CR>", {})

                        -- Custom Actions
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader><Enter>",
                            "<Cmd>lua require('r.run').action('')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>rg",
                            "<Cmd>lua require('r.run').action('glimpse')<CR>", {})
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
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>V",
                            "<Cmd>lua require('r.run').action('(function(data) { data |> View() })')<CR>",
                            {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<leader>V",
                            "<Cmd>lua require('r.run').action('(function(data) { data |> View() })')<CR>",
                            {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>hgd",
                            "<Cmd>lua require('r.send').cmd('hgd()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>tm",
                            "<Cmd>lua require('r.send').cmd('targets::tar_make()')<CR>", {})
                        vim.api.nvim_buf_set_keymap(0, "n", "<leader>tv",
                            "<Cmd>lua require('r.send').cmd('targets::tar_visnetwork()')<CR>", {})
                    end
                },

                -- Disable some default commands
                disable_cmds = {
                    "RClearConsole",
                    "RCustomStart",
                    "RSPlot",
                    "RSaveClose",
                },

                -- CONFIGURATION OPTIONS

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

                -- R Object Browser
                objbr_place = "console,below", -- place below the R console
                objbr_opendf = true,
                objbr_openlist = true,

                -- R Help & Documentation
                nvimpager = "tab", -- use vertical split for help pages

                -- View a data.frame or matrix, uses <LocalLeader>rv,
                view_df = {
                    open_app = "tmux new-window vd", -- How to open the CSV
                },

                -- Syntax Highlighting,
                Rout_more_colors = true, -- R commands in R output, .Rout files, are highlighted
            }

            -- Call the setup function with the options
            require("r").setup(setup_options)

            -- R output is highlighted with current colorscheme
            vim.g.rout_follow_colorscheme = true

            -- FOLDING BASED ON R HEADINGS ##############################
            function _G.R_heading_fold(lnum)
                local s = vim.fn.getline(lnum)

                -- Header lines
                if s:match("^%s*###%s") then return 3 end -- H3
                if s:match("^%s*##%s") then return 2 end  -- H2
                if s:match("^%s*#%s") then return 1 end   -- H1

                -- Non-header: inherit nearest previous header, but one level deeper so
                -- folds start *after* the header and end at the next header of same/higher level
                for i = lnum - 1, 1, -1 do
                    local p = vim.fn.getline(i)
                    if p:match("^%s*###%s") then return 4 end -- content under H3
                    if p:match("^%s*##%s") then return 3 end  -- content under H2
                    if p:match("^%s*#%s") then return 2 end   -- content under H1
                end
                return 0                                      -- before first header
            end

            local grp = vim.api.nvim_create_augroup("RHeadingFolds", { clear = true })

            vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
                group = grp,
                callback = function(ev)
                    if vim.bo[ev.buf].filetype ~= "r" then return end
                    local win = ev.win or vim.api.nvim_get_current_win()
                    vim.api.nvim_set_option_value("foldenable", true, { win = win })
                    vim.api.nvim_set_option_value("foldmethod", "expr", { win = win })
                    vim.api.nvim_set_option_value("foldexpr", "v:lua.R_heading_fold(v:lnum)", { win = win })
                    vim.api.nvim_set_option_value("foldlevelstart", 99, { win = win })
                    vim.api.nvim_set_option_value("foldignore", "", { win = win })
                end,
            })

            -- OBJECT BROWSER IN A FLOATING WINDOW ##########################
            -- <leader>ro => toggle R.nvim Object Browser in a floating popup
            do
                local ob = { win = nil, buf = nil }
                local api = vim.api
                local OB_PAT = vim.g.rnvim_objbr_name_pat or "Object_Browser" -- override if yours differs
                -- NEW: start/open via R.nvim, float the OB, and ensure-with-retry
                -- place right after: local ob, api, OB_PAT
                local find_objbr_win, find_objbr_buf -- NEW (forward declarations)

                local function is_objbr_buf(b)
                    if not (b and api.nvim_buf_is_valid(b)) then return false end
                    local name = api.nvim_buf_get_name(b)
                    return type(name) == "string" and name:find(OB_PAT) ~= nil
                end

                find_objbr_win = function() -- CHANGED: assign to the forward-declared local
                    for _, w in ipairs(api.nvim_list_wins()) do
                        local b = api.nvim_win_get_buf(w)
                        if is_objbr_buf(b) then return w, b end
                    end
                end

                find_objbr_buf = function() -- CHANGED: assign to the forward-declared local
                    for _, b in ipairs(api.nvim_list_bufs()) do
                        if is_objbr_buf(b) then return b end
                    end
                end


                local function start_objbr()
                    -- Send <Plug>ROBToggle command to toggle it (if not already open)
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>ROBToggle", true, true, true), "n", false)
                end

                local function float_objbr()
                    local win, buf = find_objbr_win()
                    buf = buf or find_objbr_buf()
                    if not (buf and vim.api.nvim_buf_is_valid(buf)) then
                        return false
                    end

                    -- Open FLOAT first (keeps buf alive even if the split closes)
                    local W = math.floor(vim.o.columns * 0.35)
                    local H = math.floor(vim.o.lines * 0.60)
                    local float = vim.api.nvim_open_win(buf, true, {
                        relative = "editor",
                        width = W,
                        height = H,
                        row = math.floor((vim.o.lines - H) / 2),
                        col = vim.o.columns - W - 2,
                        border = "rounded",
                        style = "minimal",
                        noautocmd = true,
                    })

                    -- Close the original OB split if it exists and isn't our float
                    if win and vim.api.nvim_win_is_valid(win) and win ~= float then
                        pcall(vim.api.nvim_win_close, win, true)
                    end

                    ob.win, ob.buf = float, buf
                    return true
                end

                local function ensure_objbr_then_float()
                    -- If neither buffer nor window exists, start one
                    local w0, b0 = find_objbr_win()
                    if not (b0 or w0) then start_objbr() end

                    -- Retry a few times while R.nvim creates the buffer/window
                    local tries, interval = 30, 50 -- ~1.5s max
                    local function step()
                        if float_objbr() then return end
                        tries = tries - 1
                        if tries <= 0 then
                            vim.notify("Object_Browser not found after starting.", vim.log.levels.WARN)
                            return
                        end
                        vim.defer_fn(step, interval)
                    end
                    vim.defer_fn(step, 60)
                end

                vim.keymap.set("n", "<leader>ro", function()
                    if ob.win and api.nvim_win_is_valid(ob.win) then
                        api.nvim_win_close(ob.win, true)
                        ob.win, ob.buf = nil, nil
                        return
                    end
                    ensure_objbr_then_float() -- start if missing, then float
                end, { desc = "R.nvim Object Browser (FLOAT toggle)" })
            end
        end,
    },
}
