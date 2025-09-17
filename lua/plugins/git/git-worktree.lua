return {
    {
        'polarmutex/git-worktree.nvim',
        version = '^2',
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            -- Setup Sesh hooks
            require("config.git-worktree-helpers").enable_sesh_hooks()
            local Hooks = require("git-worktree.hooks")
            Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)
            -- tab-local cd
            Hooks.register(Hooks.type.SWITCH, function(path)
                vim.cmd.tcd(path) -- v2 equivalent of change_directory_command = "tcd"
            end)

            -- Keymaps
            -- Create worktree from branch (or new branch from remote)
            vim.keymap.set("n", "<leader>wtc", function()
                vim.ui.input({ prompt = "New worktree from branch: " }, function(b)
                    if b and #b > 0 then require("config.git-worktree-helpers").create(b, "origin") end
                end)
            end, { desc = "Worktree: create (repo/<branch>)" })

            -- Switch to worktree by branch or path
            vim.keymap.set("n", "<leader>wts", function()
                vim.ui.input({ prompt = "Switch to worktree (branch or path): " }, function(x)
                    if x and #x > 0 then require("config.git-worktree-helpers").switch(x) end
                end)
            end, { desc = "Worktree: switch" })

            -- Delete worktree by branch or path (force)
            vim.keymap.set("n", "<leader>wtd", function()
                vim.ui.input({ prompt = "Delete worktree (branch or path): " }, function(x)
                    if x and #x > 0 then require("config.git-worktree-helpers").delete(x, true) end
                end)
            end, { desc = "Worktree: delete (force) + prune" })

            -- Delete worktree and remote branch
            vim.keymap.set("n", "<leader>wtx", function()
                vim.ui.input({ prompt = "Delete worktree & remote (branch): " }, function(b)
                    if b and #b > 0 then require("config.git-worktree-helpers").delete_with_remote(b, "origin") end
                end)
            end, { desc = "Worktree: delete + remote branch" })

            -- Alternate telescope keymaps
            vim.keymap.set("n", "<leader>wtl", function()
                require("telescope").extensions.git_worktree.git_worktree()
            end, { desc = "Worktrees: list" })

            vim.keymap.set("n", "<leader>wtn", function()
                local helpers = require("config.git-worktree-helpers")
                local default_base = helpers.default_base("origin")
                vim.ui.input({ prompt = ("Base (branch/tag/SHA) [default: %s]:"):format(default_base) }, function(base)
                    base = (base and #base > 0) and base or default_base
                    vim.ui.input({ prompt = "New branch name:" }, function(nb)
                        if nb and #nb > 0 then helpers.create_branch_from(base, nb, "origin") end
                    end)
                end)
            end, { desc = "Worktree: new branch from base → add & switch" })

            vim.keymap.set("n", "<leader>wtW", function()
                require("telescope").extensions.git_worktree.git_worktree({
                    -- Custom key mappings while in the picker
                    attach_mappings = function(_, map)
                        local actions = require("telescope.actions")
                        local action_state = require("telescope.actions.state")
                        -- Create new branch from branch (or remote) under cursor and then new worktree from that
                        map({ "i", "n" }, "<C-n>", function(prompt_bufnr)
                            local entry = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            vim.ui.input({ prompt = "New branch name: " }, function(nb)
                                if nb and #nb > 0 then
                                    require("config.git-worktree-helpers").create_branch_from(entry.branch or entry.value.branch,
                                        nb, "origin")
                                end
                            end)
                        end)
                        -- Delete workree (force) + prune, without deleting remote branch
                        map({ "i", "n" }, "<C-x>", function(prompt_bufnr)
                            local entry = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            require("config.git-worktree-helpers").delete_with_remote(entry.branch or entry.value.branch,
                                "origin")
                        end)
                        -- Delete worktree and remote branch
                        map({ "i", "n" }, "<C-X>", function(prompt_bufnr)
                            local entry = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            require("config.git-worktree-helpers").delete_with_remote(entry.branch or entry.value.branch,
                                "origin")
                        end)
                        return true
                    end,
                })
            end, { desc = "Worktrees: list (C-x = delete+remote)" })
        end
    }
    -- {
    --     "zkygr/git-worktree.nvim",
    --     branch = "fix/create_branches_from_remote_ref",
    --     config = function()
    --         require("git-worktree").setup({
    --             change_directory_command = "cd",
    --             update_on_change = true,
    --             update_on_change_command = "v .",
    --             clearjumps_on_change = true,
    --             autopush = false,
    --         })
    --     end,
    -- },
    -- {
    --     -- Changes how branches are created from remote refs
    --     "anthonyokc/git-worktree.nvim",
    --     config = function()
    --         require("git-worktree").setup({
    --             change_directory_command = "cd",
    --             update_on_change = true,
    --             update_on_change_command = "v .",
    --             clearjumps_on_change = true,
    --             autopush = false,
    --         })
    --     end,
    -- },
    -- {
    --     "ThePrimeagen/git-worktree.nvim",
    --     config = function()
    --         require("git-worktree").setup({
    --             change_directory_command = "cd",
    --             update_on_change = true,
    --             update_on_change_command = "v .",
    --             clearjumps_on_change = true,
    --             autopush = false,
    --         })
    --     end,
    -- },
}
