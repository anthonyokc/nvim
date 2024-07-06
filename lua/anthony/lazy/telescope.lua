return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.6",

    dependencies = {
        "nvim-lua/plenary.nvim",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },

    config = function()
        local actions = require("telescope.actions")
        local action_state = require('telescope.actions.state')
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
                    },
                },
                layout_config = {
                    preview_width = 0.55,
                    horizontal = {
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

        local builtin = require('telescope.builtin')
        require('telescope').load_extension('noice')
        require('telescope').load_extension('fzf')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- search project files
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
        vim.keymap.set("n", "<leader>fd", builtin.lsp_document_symbols, { desc = "Find Symbols" })
        vim.keymap.set("n", "<leader>fi", "<cmd>AdvancedGitSearch<CR>", { desc = "AdvancedGitSearch" })
        vim.keymap.set('n', '<leader>fn', "<cmd>Telescope notify<CR>", {})  -- search notifications
        vim.keymap.set('n', '<leader>fN', "<cmd>Telescope noice<CR>", {})   -- search notifications
        vim.keymap.set('n', '<leader>fy', "<cmd>Telescope neoclip<CR>", {}) -- search notifications
        vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
        vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search Git Commits" })
        vim.keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "Search Git Commits for Buffer" })
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})                 -- search git files
        vim.keymap.set('n', '<leader>fws', function()                       -- search highlighted word
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>fWs', function() -- search full highlighted word
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>fs', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end
}
