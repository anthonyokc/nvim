return {
    {
        'NickvanDyke/opencode.nvim',
        event = 'VeryLazy',
        dependencies = {
            -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
            { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
        },
        config = function()
            vim.g.opencode_opts = {
                terminal = {
                    win = { 
                        enter = true,
                        bo = { filetype = "opencode_terminal" },
                    },
                },
            }

            -- Required for `opts.auto_reload`
            vim.opt.autoread = true

            -- Set up keymaps for opencode terminal to exit insert mode with Ctrl+C or Esc
            vim.api.nvim_create_autocmd("TermOpen", {
                group = vim.api.nvim_create_augroup("OpencodeTerminalKeymaps", { clear = true }),
                callback = function(args)
                    if vim.bo[args.buf].filetype == "opencode_terminal" then
                        -- Exit insert mode with Ctrl+C
                        vim.keymap.set('t', '<C-c>', function()
                            vim.cmd("stopinsert")
                        end, { buffer = args.buf, desc = "Exit insert mode with Ctrl+C" })
                        
                        -- Exit insert mode with single Esc
                        vim.keymap.set('t', '<esc>', function()
                            vim.cmd("stopinsert")
                        end, { buffer = args.buf, desc = "Exit insert mode with Esc" })
                    end
                end,
            })

            -- Core opencode functionality keymaps
            -- Toggle opencode interface
            vim.keymap.set('n', '<leader>ot', function()
                require('opencode').toggle()
            end, { desc = 'Toggle opencode' })

            -- Ask opencode questions
            vim.keymap.set('n', '<leader>oA', function()
                require('opencode').ask()
            end, { desc = 'Ask opencode' })
            vim.keymap.set('n', '<leader>oa', function()
                require('opencode').ask('@cursor: ')
            end, { desc = 'Ask opencode about this' })
            vim.keymap.set('v', '<leader>oa', function()
                require('opencode').ask('@selection: ')
            end, { desc = 'Ask opencode about selection' })

            -- Session and message management
            vim.keymap.set('n', '<leader>on', function()
                require('opencode').command('session_new')
            end, { desc = 'New opencode session' })
            vim.keymap.set('n', '<leader>oy', function()
                require('opencode').command('messages_copy')
            end, { desc = 'Copy last opencode response' })
            
            -- Abort current generation and kill session (custom keybinds)
            vim.keymap.set('n', '<leader>ok', function()
                require('opencode').command('session_interrupt')
            end, { desc = 'Kill current opencode generation' })
            vim.keymap.set('n', '<leader>oq', function()
                require('opencode').command('app_exit')
            end, { desc = 'Quit opencode session' })

            -- Navigation keymaps
            vim.keymap.set('n', '<S-C-u>', function()
                require('opencode').command('messages_half_page_up')
            end, { desc = 'Messages half page up' })
            vim.keymap.set('n', '<S-C-d>', function()
                require('opencode').command('messages_half_page_down')
            end, { desc = 'Messages half page down' })

            -- Prompt selection
            vim.keymap.set({ 'n', 'v' }, '<leader>os', function()
                require('opencode').select()
            end, { desc = 'Select opencode prompt' })

            -- Example: keymap for custom prompt
            vim.keymap.set('n', '<leader>oe',
                function() require('opencode').prompt('Explain @cursor and its context') end,
                { desc = 'Explain this code' })
        end,
    },
}