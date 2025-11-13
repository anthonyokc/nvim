local function compiler_default_components()
    return {
        { "on_complete_notify", statuses = {} },
        "default",
        "on_result_diagnostics",
        "unique",
        {
            "open_output",
            direction = "float",
            focus = true,
            on_complete = "failure",
            on_start = "never",
        },
    }
end

return {
    { -- This plugin
        "Zeioth/compiler.nvim",
        event = "VeryLazy",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo", "CompilerStop" },
        dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" }, -- there are also system dependencies for the compilers themselves [this may or not be how you want them installed]: https://github.com/Zeioth/Compiler.nvim/wiki/how-to-install-the-required-dependencies
        opts = {},
        config = function (_, opts)
            require("compiler").setup(opts)

            local function configure_compiler_dropdown()
                local ok, compiler_telescope = pcall(require, "compiler.telescope")
                if not ok then
                    vim.notify("compiler.nvim UI override failed to load telescope backend", vim.log.levels.WARN,
                        { title = "Compiler.nvim" })
                    return
                end

                local default_show = compiler_telescope.show

                local function dropdown_show()
                    if vim.loop.os_homedir() == vim.loop.cwd() then
                        vim.notify("You must :cd your project dir first.\nHome is not allowed as working dir.",
                            vim.log.levels.WARN, { title = "Compiler.nvim" })
                        return
                    end

                    local conf = require("telescope.config").values
                    local actions = require("telescope.actions")
                    local state = require("telescope.actions.state")
                    local pickers = require("telescope.pickers")
                    local finders = require("telescope.finders")
                    local utils = require("compiler.utils")
                    local utils_bau = require("compiler.utils-bau")
                    local themes = require("telescope.themes")

                    local buffer = vim.api.nvim_get_current_buf()
                    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })
                    local language = utils.require_language(filetype) or utils.require_language("make") or {}
                    local options = vim.deepcopy(language.options or {})

                    local bau_opts = utils_bau.get_bau_opts()
                    local last_bau_value
                    for _, item in ipairs(bau_opts) do
                        if last_bau_value ~= item.bau then
                            table.insert(options, { text = "", value = "separator" })
                            last_bau_value = item.bau
                        end
                        table.insert(options, item)
                    end

                    local numbered = {}
                    local index_counter = 0
                    for _, option in ipairs(options) do
                        if option.value ~= "separator" then
                            index_counter = index_counter + 1
                            if not option.text:match("^%d+ %-%s") then
                                option.text = index_counter .. " - " .. option.text
                            end
                        end
                        table.insert(numbered, option)
                    end

                    local function on_option_selected(prompt_bufnr)
                        actions.close(prompt_bufnr)
                        local selection = state.get_selected_entry()
                        if not selection or selection.value == "" then
                            return
                        end

                        local bau
                        for _, value in ipairs(numbered) do
                            if value.text == selection.display then
                                bau = value.bau
                                break
                            end
                        end

                        if bau then
                            bau = utils_bau.require_bau(bau)
                            if bau then bau.action(selection.value) end
                            _G.compiler_redo_selection = nil
                            _G.compiler_redo_bau_selection = selection.value
                            _G.compiler_redo_bau = bau
                        else
                            if language.action then
                                language.action(selection.value)
                            end
                            _G.compiler_redo_selection = selection.value
                            _G.compiler_redo_filetype = filetype
                            _G.compiler_redo_bau_selection = nil
                            _G.compiler_redo_bau = nil
                        end
                    end

                    local dropdown = themes.get_dropdown({
                        previewer = false,
                        layout_config = { width = 0.55, height = 0.6 },
                        sorting_strategy = "ascending",
                    })

                    pickers
                        .new(dropdown, {
                            prompt_title = "Compiler",
                            results_title = "Options",
                            finder = finders.new_table {
                                results = numbered,
                                entry_maker = function(entry)
                                    return {
                                        display = entry.text,
                                        value = entry.value,
                                        ordinal = entry.text,
                                    }
                                end,
                            },
                            sorter = conf.generic_sorter(),
                            attach_mappings = function(_, map)
                                map("i", "<CR>", function(prompt_bufnr) on_option_selected(prompt_bufnr) end)
                                map("n", "<CR>", function(prompt_bufnr) on_option_selected(prompt_bufnr) end)
                                return true
                            end,
                        })
                        :find()
                end

                compiler_telescope.show = function(...)
                    local ok_override, err = pcall(dropdown_show, ...)
                    if not ok_override then
                        vim.notify("Compiler UI override failed. Falling back to upstream UI.\n" .. err,
                            vim.log.levels.WARN, { title = "Compiler.nvim" })
                        return default_show(...)
                    end
                end
            end

            configure_compiler_dropdown()

            local function override_default_alias()
                local ok, overseer_mod = pcall(require, "overseer")
                if not ok then
                    return
                end
                overseer_mod.register_alias("default_extended", compiler_default_components())
            end
            override_default_alias()

            -- Open compiler
            vim.keymap.set("n", "<leader>bo", "<cmd>CompilerOpen<cr>", { noremap = true, silent = true, desc = "Compiler: open UI" })

            -- Redo last selected option
            vim.keymap.set("n", "<leader>br",
                 "<cmd>CompilerStop<cr>" -- (Optional, to dispose all tasks before redo)
              .. "<cmd>CompilerRedo<cr>",
             { noremap = true, silent = true, desc = "Compiler: redo last option" })

            -- Toggle compiler results
            vim.keymap.set("n", "<leader>bt", "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true, desc = "Compiler: toggle results" })
        end
    },
    { -- The task runner we use
        "stevearc/overseer.nvim",
        version = "1.6.0",
        event = "VeryLazy",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo", "CompilerStop" },
        opts = {
            task_list = {
                direction = "right",
                max_width = { 100, 0.5 },
                -- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
                min_width = { 30, 0.2 },
                -- optionally define an integer/float for the exact width of the task list
                --width = 0.5,
                default_detail = 1
            },
        },
        config = function(_, opts)
            local overseer = require("overseer")
            overseer.setup(opts)

            local function get_shell()
                local is_win = (vim.loop.os_uname().sysname or ""):match("Windows")
                if is_win then
                    return "cmd", "/C"
                end
                return "bash", "-lc"
            end

            local function ts_runner(file)
                if vim.fn.executable("tsx") == 1 then
                    return ("tsx %q"):format(file)
                end
                if vim.fn.executable("ts-node") == 1 then
                    return ("ts-node %q"):format(file)
                end
                return ("npx ts-node %q"):format(file)
            end

            local default_components = compiler_default_components()

            overseer.register_template({
                name = "Build & run current file",
                builder = function()
                    local file     = vim.fn.expand("%:p")
                    local out      = vim.fn.expand("%:p:r")
                    local ft       = vim.bo.filetype
                    local sh, flag = get_shell()

                    local function run_ts()
                        return ts_runner(file)
                    end

                    local node_cmd   = ("node %q"):format(file)
                    local ts_cmd     = run_ts()

                    local cmd      = ({
                        c               = ("gcc %q -O2 -g -o %q && %q"):format(file, out, out),
                        cpp             = ("g++ %q -O2 -g -std=c++20 -o %q && %q"):format(file, out, out),
                        rust            = ("rustc %q -o %q && %q"):format(file, out, out),
                        go              = ("go run %q"):format(file),
                        python          = ("python3 %q"):format(file),
                        lua             = ("lua %q"):format(file),
                        sh              = ("bash %q"):format(file),
                        ruby            = ("ruby %q"):format(file),
                        javascript      = node_cmd,
                        javascriptreact = node_cmd,
                        node            = node_cmd,
                        typescript      = ts_cmd,
                        typescriptreact = ts_cmd,
                    })[ft]

                    if not cmd then
                        vim.notify("No build&run template for filetype: " .. ft, vim.log.levels.ERROR)
                        return
                    end
                    return {
                        cmd = { sh, flag },
                        args = { cmd },
                        components = vim.deepcopy(default_components),
                    }
                end,
                condition = { callback = function() return vim.fn.filereadable(vim.fn.expand("%:p")) == 1 end },
            })

            local function register_simple_runner(def)
                overseer.register_template({
                    name = def.name,
                    condition = { filetype = def.filetypes },
                    builder = function()
                        local file = vim.fn.expand("%:p")
                        if vim.fn.filereadable(file) ~= 1 then
                            vim.notify("Save the file you want to run before invoking " .. def.name,
                                vim.log.levels.WARN, { title = "Overseer" })
                            return
                        end
                        local cmd_str = def.command(file)
                        if not cmd_str or cmd_str == "" then
                            return
                        end
                        local sh, flag = get_shell()
                        return {
                            cmd = { sh, flag },
                            args = { cmd_str },
                            components = vim.deepcopy(def.components or default_components),
                        }
                    end,
                })
            end

            register_simple_runner({
                name = "Ruby: Run current file",
                filetypes = { "ruby" },
                command = function(file)
                    local join = (vim.fs and vim.fs.joinpath) or function(...) return table.concat({ ... }, "/") end
                    local cwd = vim.loop.cwd()
                    local use_bundle = vim.fn.filereadable(join(cwd, "Gemfile")) == 1
                        or vim.fn.filereadable(join(cwd, "Gemfile.lock")) == 1
                    local runner = use_bundle and "bundle exec ruby" or "ruby"
                    return ("%s %q"):format(runner, file)
                end,
            })

            register_simple_runner({
                name = "Node: Run current file",
                filetypes = { "javascript", "javascriptreact", "node" },
                command = function(file)
                    local runner = vim.fn.executable("bun") == 1 and "bun run" or "node"
                    return ("%s %q"):format(runner, file)
                end,
            })

            register_simple_runner({
                name = "TypeScript: Run current file",
                filetypes = { "typescript", "typescriptreact" },
                command = ts_runner,
            })

            local language_template_lookup = {
                ruby = "Ruby: Run current file",
                javascript = "Node: Run current file",
                javascriptreact = "Node: Run current file",
                node = "Node: Run current file",
                typescript = "TypeScript: Run current file",
                typescriptreact = "TypeScript: Run current file",
            }

            -- Keymap (put anywhere)
            vim.keymap.set("n", "<leader>bb", function()
                local template = language_template_lookup[vim.bo.filetype] or "Build & run current file"
                overseer.run_template({ name = template })
                local previous_window = vim.api.nvim_get_current_win()
                vim.cmd("OverseerOpen")
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(previous_window) then
                        vim.api.nvim_set_current_win(previous_window)
                    end
                end)
            end, { desc = "Run current file with Overseer" })
        end
    },
}
