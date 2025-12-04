return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
            { "aaronhallaert/advanced-git-search.nvim" },
        },
        cmd = Telescope,
        keys = { "<leader>f" }, -- Lazy load on <leader>f
        config = function()
            local actions = require("telescope.actions")
            local action_state = require('telescope.actions.state')
            local open_with_trouble = require("trouble.sources.telescope").open -- Use this to open the trouble list
            local add_to_trouble = require("trouble.sources.telescope")
                .add                                                            -- Use this to add more results without clearing the trouble list
            local builtin = require('telescope.builtin')

            local function copy_to_clipboard()
                local entry = action_state.get_selected_entry()
                if entry and entry.value then
                    vim.fn.setreg('+', entry.value)
                    print('Copied to clipboard: ' .. entry.value)
                else
                    print('No entry selected or entry has no value')
                end
            end

            require('telescope').setup({
                defaults = {
                    layout_strategy = 'horizontal',
                    layout_config = {
                        horizontal = {
                            preview_width = 0.55,
                            width = 0.9,
                        }
                    },
                    defaults = {
                        -- Important for performance with large repositories
                        sorting_strategy = "descending",
                        layout_strategy = "horizontal",
                        dynamic_preview_title = true,
                    },
                    extensions = {
                        fzf = {
                            fuzzy = true,                    -- false will only do exact matching
                            override_generic_sorter = true,  -- override the generic sorter
                            override_file_sorter = true,     -- override the file sorter
                            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                        },
                    },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-y>"] = function(prompt_bufnr)
                                copy_to_clipboard()
                                actions.close(prompt_bufnr)
                            end,
                            ["<C-t>"] = open_with_trouble,
                        },
                        n = { ["<C-t>"] = open_with_trouble },
                    },
                },
                pickers = {
                    find_files = {
                        -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
            })

            -- Load extensions
            require('telescope').load_extension('noice')
            require('telescope').load_extension('fzf')
            require('telescope').load_extension('git_worktree')
            require('telescope').load_extension("advanced_git_search")

            -- File and buffer operations
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
            vim.keymap.set('n', '<leader>fF', builtin.git_files, { desc = "Find Git Files" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })

            -- Search operations
            vim.keymap.set("n", "<leader>fg", function()
                builtin.live_grep {
                    additional_args = function()
                        -- TODO: Maybe have R only settings, or a toggle?
                        return {
                            "--hidden",
                            "--glob=!.git/*",
                            "--glob=!node_modules/*",
                            "--glob=!dist/*",
                            "--glob=!*.html",
                            "--glob=!*.css",
                            "--glob=!*.scss",
                            "--glob=!*.js",
                            "--glob=!*.json",
                            "--glob=!*.csv"
                        }
                    end,
                }
            end, { desc = "Find with Live Grep (rg)" })

            vim.keymap.set('n', '<leader>fG', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end, { desc = "Find with Grep String" })
            vim.keymap.set('n', '<leader>fws', function()
                local word = vim.fn.expand("<cword>")
                builtin.grep_string({ search = word })
            end, { desc = "Find Highlighted Word" })
            vim.keymap.set('n', '<leader>fWs', function()
                local word = vim.fn.expand("<cWORD>")
                builtin.grep_string({ search = word })
            end, { desc = "Find Full Highlighted Word" })

            -- Git operations
            vim.keymap.set("n", "<leader>fc", builtin.git_commits, { desc = "Find Git Commits" })
            vim.keymap.set("n", "<leader>fC", builtin.git_bcommits, { desc = "Find Git Commits for Buffer" })
            vim.keymap.set("n", "<leader>fi", "<cmd>AdvancedGitSearch<CR>", { desc = "Find with Advanced Git Search" })
            -- Git Worktree operations
            vim.keymap.set("n", "<leader>fr", "<CMD>lua require('telescope').extensions.git_worktree.git_worktree()<CR>",
                { desc = "Find Git Worktree" })
            vim.keymap.set("n", "<leader>fR",
                "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree({prefix = '../'})<CR>",
                { desc = "Create Git Worktree" })

            -- LSP and diagnostics
            vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Find Diagnostics" })
            vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols" })

            -- Help and keymaps
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
            vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })

            -- Unified notifications picker
            local function notifications_picker()
                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values

                local entries = {}

                -- grab from notify plugin if available
                local notify_ok, notify = pcall(require, "notify")
                if notify_ok and notify.history then
                    local notify_history = notify.history() or {}
                    for _, n in ipairs(notify_history) do
                        local message = type(n.message) == "table" and vim.inspect(n.message) or
                            tostring(n.message or "unknown")
                        table.insert(entries, "[notify] " .. message)
                    end
                end

                -- grab from noice plugin if available
                local noice_ok, noice = pcall(require, "noice")
                if noice_ok and noice.api and noice.api.history and noice.api.history.list then
                    local noice_history = noice.api.history.list() or {}
                    for _, n in ipairs(noice_history) do
                        local message = type(n.message) == "table" and vim.inspect(n.message) or
                            tostring(n.message or n.event or "unknown")
                        table.insert(entries, "[noice] " .. message)
                    end
                end

                if #entries == 0 then
                    table.insert(entries, "No notifications found")
                end

                pickers.new({}, {
                    prompt_title = "Notifications",
                    finder = finders.new_table(entries),
                    sorter = conf.generic_sorter({}),
                }):find()
            end

            -- Notifications and clipboard
            vim.keymap.set('n', '<leader>fn', "<cmd>Telescope notify<CR>", { desc = "Find Notifications" })
            vim.keymap.set('n', '<leader>fN', "<cmd>Telescope noice<CR>", { desc = "Find Noice Messages" })
            vim.keymap.set('n', '<leader>fun', notifications_picker, { desc = "Find All Notifications" })
            vim.keymap.set('n', '<leader>fy', "<cmd>Telescope neoclip<CR>", { desc = "Find Clipboard History" })

            -- Harpoon
            vim.keymap.set('n', '<leader>fm', "<cmd>Telescope harpoon marks<cr>", { desc = "Find Harpoon Marks" })
        end
    },
    {
        -- A fast file finder and more written in Rust
        "dmtrKovalenko/fff.nvim",
        build = "cargo build --release",
        -- or if you are using nixos
        -- build = "nix run .#release",
        opts = {
            prompt = "🤠 ",
            title = "fff.nvim",
            lazy_sync = false,
            max_results = 50,
            max_threads = 99, -- FULL THROTTLE
            layout = {
                width = 0.9,
                height = 0.9,
            },
            preview = {
                max_size = 5 * 1024 * 1024, -- Do not try to read files larger than 5MB
                chunk_size = 2048,          -- half the default, ~8kb for 50-100 lines
                line_numbers = true,
            },
            keymaps = {
                close = { '<Esc>', '<C-c>' },
                move_up = { '<Up>', '<C-k>', '<C-p>' },
                move_down = { '<Down>', '<C-j>', '<C-n>' },
            },

            debug = {
                show_scores = false, -- Toggle with F2 or :FFFDebug
            },
        },
        keys = {
            {
                "ff",
                function()
                    require("fff").find_files() -- or find_in_git_root() if you only want git files
                end,
                desc = "Open file picker",
            },
        },
    }
}
