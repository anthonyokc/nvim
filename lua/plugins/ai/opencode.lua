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

            -- Enhanced auto-reload: SSE-based + polling fallback
            local opencode_timer = nil
            local sse_connected = false


            local function start_polling_fallback()
                if opencode_timer then
                    vim.fn.timer_stop(opencode_timer)
                end
                opencode_timer = vim.fn.timer_start(5000, function()
                    vim.cmd('silent! checktime')
                    -- vim.notify("[opencode] Polling fallback: checked for file changes", vim.log.levels.TRACE)
                end, { ['repeat'] = -1 })
            end

            local function stop_polling_fallback()
                if opencode_timer then
                    vim.fn.timer_stop(opencode_timer)
                    opencode_timer = nil
                end
            end


            -- Connect to SSE and setup auto-reload when opencode terminal opens
            vim.api.nvim_create_autocmd("TermOpen", {
                group = vim.api.nvim_create_augroup("OpencodeAutoReloadSSE", { clear = true }),
                callback = function(args)
                    if vim.bo[args.buf].filetype == "opencode_terminal" and not sse_connected then
                        -- Setup the built-in SSE-based auto-reload
                        require("opencode.reload").setup()



                        -- Connect to SSE for real-time file.edited events
                        require("opencode.server").get_port(function(ok, port)
                            if ok then
                                require("opencode.client").listen_to_sse(port, function(event)
                                    vim.api.nvim_exec_autocmds("User", {
                                        pattern = "OpencodeEvent",
                                        data = event,
                                    })

                                    -- Check for file.edited events (original design)
                                    if event.type == "file.edited" then
                                        vim.cmd('silent! checktime')
                                    end

                                    -- Check for edit tool completion events
                                    if event.type == "message.part.updated" and
                                       event.properties and
                                       event.properties.part and
                                       event.properties.part.tool == "edit" and
                                       event.properties.part.state and
                                       event.properties.part.state.status == "completed" then
                                        local filePath = event.properties.part.state.input and event.properties.part.state.input.filePath
                                        local oldString = event.properties.part.state.input and event.properties.part.state.input.oldString
                                        local newString = event.properties.part.state.input and event.properties.part.state.input.newString
                                    end

                                    -- Also check for write tool events
                                    if event.type == "message.part.updated" and
                                       event.properties and
                                       event.properties.part and
                                       event.properties.part.tool == "write" and
                                       event.properties.part.state and
                                       event.properties.part.state.status == "completed" then
                                        local filePath = event.properties.part.state.input and event.properties.part.state.input.filePath
                                        if filePath then
                                            vim.schedule(function()
                                                vim.cmd('silent! checktime')
                                            end)
                                        end
                                    end
                                end)
                                sse_connected = true
                            else
                                -- SSE failed, use polling fallback
                                vim.notify("[opencode] SSE failed, using polling fallback", vim.log.levels.WARN)
                                start_polling_fallback()
                            end
                        end)
                    end
                end,
            })

            -- Cleanup when opencode terminal closes
            vim.api.nvim_create_autocmd("TermClose", {
                group = vim.api.nvim_create_augroup("OpencodeAutoReloadCleanup", { clear = true }),
                callback = function(args)
                    if vim.bo[args.buf].filetype == "opencode_terminal" then
                        stop_polling_fallback()
                        sse_connected = false
                    end
                end,
            })



            -- Set up keymaps for opencode terminal to exit insert mode with Ctrl+C or Esc
            vim.api.nvim_create_autocmd("TermOpen", {
                group = vim.api.nvim_create_augroup("OpencodeTerminalKeymaps", { clear = true }),
                callback = function(args)
                    if vim.bo[args.buf].filetype == "opencode_terminal" then
                        -- Disable textwidth for opencode terminal to prevent line wrapping
                        vim.bo[args.buf].textwidth = 0

                        -- Exit insert mode with Ctrl+C
                        vim.keymap.set('t', '<C-c>', function()
                            vim.cmd("stopinsert")
                        end, { buffer = args.buf, desc = "Exit insert mode with Ctrl+C" })

                        -- NOTE: This can interfere with the Esc key usage so
                        -- commented out until that keybinding can be modified
                        -- Exit insert mode with single Esc
                        -- vim.keymap.set('t', '<esc>', function()
                        --     vim.cmd("stopinsert")
                        -- end, { buffer = args.buf, desc = "Exit insert mode with Esc" })
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
