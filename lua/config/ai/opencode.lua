local M = {}

-- Module-level state
local opencode_timer = nil
local sse_connected = false

-- Configure global options
local function configure_globals()
    vim.g.opencode_opts = {
        provider = {
            enabled = "snacks",
            snacks = {
            },
        },
    }

    -- Required for `opts.auto_reload`
    vim.opt.autoread = true
end

-- Guard provider start function to prevent double starts
local function guard_provider()
    local provider_module = require("opencode.provider")
    if provider_module and provider_module.start and not provider_module._opencode_start_guard then
        local original_start = provider_module.start
        provider_module.start = function(...)
            if provider_module._opencode_skip_next_start then
                provider_module._opencode_skip_next_start = false
                return
            end
            return original_start(...)
        end
        provider_module._opencode_start_guard = original_start
    end

    local function skip_next_provider_start()
        if not (provider_module and provider_module._opencode_start_guard) then
            return function() end
        end
        provider_module._opencode_skip_next_start = true
        return function()
            if provider_module then
                provider_module._opencode_skip_next_start = false
            end
        end
    end

    return skip_next_provider_start
end

-- Polling fallback functions
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

-- Setup auto-reload with SSE and polling fallback
local function setup_auto_reload()
    local skip_next_provider_start = guard_provider()

    -- Connect to SSE and setup auto-reload when opencode terminal opens
    vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("OpencodeAutoReloadSSE", { clear = true }),
        callback = function(args)
            if vim.bo[args.buf].filetype ~= "opencode_terminal" or sse_connected then
                return
            end

            local release_skip = function() end

            local ok, err = pcall(function()
                local server_mod = require("opencode.cli.server")
                local client_mod = require("opencode.cli.client")
                if type(server_mod) ~= "table" or type(server_mod.get_port) ~= "function"
                    or type(client_mod) ~= "table" or type(client_mod.listen_to_sse) ~= "function" then
                    error("invalid opencode SSE modules")
                end

                if not server_mod._opencode_suppress_start_notify then
                    local original_get_port = server_mod.get_port
                    server_mod.get_port = function(...)
                        local original_notify = vim.notify
                        vim.notify = function(msg, level, opts)
                            if type(msg) == "string" and msg:find("No `opencode` process") then
                                return
                            end
                            return original_notify(msg, level, opts)
                        end
                        local ok, result = pcall(original_get_port, ...)
                        vim.notify = original_notify
                        if not ok then
                            error(result)
                        end
                        return result
                    end
                    server_mod._opencode_suppress_start_notify = true
                end

                -- Connect to SSE for real-time file.edited events
                -- Delay this to prevent double terminal creation during initialization
                release_skip = skip_next_provider_start()
                vim.defer_fn(function()
                    server_mod.get_port()
                        :next(function(port)
                            release_skip()
                            release_skip = function() end
                            client_mod.listen_to_sse(port, function(event)
                                vim.api.nvim_exec_autocmds("User", {
                                    pattern = "OpencodeEvent",
                                    data = {
                                        event = event,
                                        port = port,
                                    },
                                })

                                -- Check for file.edited events (original design)
                                if event.type == "file.edited" then
                                    vim.cmd('silent! checktime')
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
                            stop_polling_fallback()
                            return port
                        end)
                        :catch(function(port_err)
                            release_skip()
                            release_skip = function() end
                            local message = "[opencode] SSE auto-reload unavailable, using polling fallback"
                            if port_err ~= nil then
                                local err_msg = type(port_err) == "string" and port_err or vim.inspect(port_err)
                                if err_msg ~= "" then
                                    message = message .. ("\n" .. err_msg)
                                end
                            end
                            vim.notify(message, vim.log.levels.WARN)
                            start_polling_fallback()
                        end)
                end, 500) -- Small delay to ensure terminal setup is complete
            end)

            if not ok then
                release_skip()
                release_skip = function() end
                local message = "[opencode] SSE auto-reload unavailable, using polling fallback"
                if type(err) == "string" and err ~= "" then
                    message = message .. ("\n" .. err)
                end
                vim.notify(message, vim.log.levels.WARN)
                start_polling_fallback()
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
end

-- Setup terminal keymaps
local function setup_terminal_keymaps()
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

                -- Exit insert mode with single Esc
                vim.keymap.set('t', '<esc>', function()
                    vim.cmd("stopinsert")
                end, { buffer = args.buf, desc = "Exit insert mode with Esc" })

                -- Navigation keymaps
                vim.keymap.set("t", "<C-u>", function()
                    require("opencode").command("session.half.page.up")
                end,   { desc = "opencode half page up" })
                vim.keymap.set("t", "<C-d>", function()
                    require("opencode").command("session.half.page.down")
                end, { desc = "opencode half page down" })
                        end
        end,
    })
end

-- Setup user keymaps
local function setup_user_keymaps()
    -- Core opencode functionality keymaps
    local function focus_opencode_terminal()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "opencode_terminal" then
                vim.api.nvim_set_current_win(win)
                break
            end
        end
    end

    -- Toggle opencode interface
    vim.keymap.set({ 'n', 't' }, '<leader>ot', function()
        require('opencode').toggle()
        focus_opencode_terminal()
    end, { desc = 'Toggle opencode' })

    -- Opencode selection interface
    vim.keymap.set({ 'n', 'v' }, '<leader>fo', function()
        require('opencode').select()
    end, { desc = 'Find opencode command' })

    -- Ask opencode questions
    vim.keymap.set('n', '<leader>oA', function()
        require('opencode').ask()
    end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n', 'v' }, '<leader>oa', function()
        require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Ask opencode about this' })

    -- Session and message management
    vim.keymap.set('n', '<leader>on', function()
        require('opencode').command('session.new')
        focus_opencode_terminal()
    end, { desc = 'New opencode session' })

    -- Abort current generation and kill session (custom keybinds)
    vim.keymap.set('n', '<leader>ok', function()
        require('opencode').command('session.interrupt')
    end, { desc = 'Interrupt current opencode generation' })


    -- Prompt selection
    vim.keymap.set({ 'n', 'v' }, '<leader>os', function()
        require('opencode').select()
    end, { desc = 'Select opencode prompt' })

    -- Example: keymap for custom prompt
    vim.keymap.set('n', '<leader>oe', function()
        require('opencode').prompt('Explain @this and its context')
    end, { desc = 'Explain this code' })
end

-- Main setup function
function M.setup()
    configure_globals()
    setup_auto_reload()
    setup_terminal_keymaps()
    setup_user_keymaps()
end

return M
