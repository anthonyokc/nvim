return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
            {
                "nvim-telescope/telescope-live-grep-args.nvim",
                -- This will not install any breaking changes.
                -- For major updates, this must be adjusted manually.
                version = "^1.0.0",
            },
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
                    layout_strategy = 'horizontal',
                    layout_config = {
                        horizontal = {
                            preview_width = 0.55,
                            width = 0.9,
                        }
                    }
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
            require('telescope').load_extension("live_grep_args")
            require('telescope').load_extension("advanced_git_search")

            -- File and buffer operations
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
            vim.keymap.set('n', '<leader>fF', builtin.git_files, { desc = "Find Git Files" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })

            -- Search operations
            vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
                { desc = "Find with Live Grep" })
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
            vim.keymap.set("n", "<leader>fr", "<CMD>lua require('telescope').extensions.git_worktree.git_worktree()<CR>",
                { desc = "Find Git Worktree" })
            vim.keymap.set("n", "<leader>fR",
                "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree({prefix = '../'})<CR>",
                { desc = "Create Git Worktree" })
            vim.keymap.set("n", "<leader>fc", builtin.git_commits, { desc = "Find Git Commits" })
            vim.keymap.set("n", "<leader>fC", builtin.git_bcommits, { desc = "Find Git Commits for Buffer" })
            vim.keymap.set("n", "<leader>fi", "<cmd>AdvancedGitSearch<CR>", { desc = "Find with Advanced Git Search" })

            -- LSP and diagnostics
            vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Find Diagnostics" })
            vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols" })

            -- Help and keymaps
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
            vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })

            -- Notifications and clipboard
            vim.keymap.set('n', '<leader>fn', "<cmd>Telescope notify<CR>", { desc = "Find Notifications" })
            vim.keymap.set('n', '<leader>fN', "<cmd>Telescope noice<CR>", { desc = "Find Noice Messages" })
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
            layout = {
                width = 0.9,
                height = 0.9,
            },
            prompt = "🤠 ",
            max_results = 70,

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
