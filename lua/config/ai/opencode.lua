local M = {}

-- Module-level state
local opencode_timer = nil
local sse_connected = false

local CODE_WINDOW_TARGET_WIDTH = 120
local TERMINAL_MIN_WIDTH = 1
local ASK_WINDOW_WIDTH = 100
local ASK_WINDOW_MAX_HEIGHT_RATIO = 0.5

local window_layout_state = {
    code = nil,
    terminals = {},
}

local function compute_wrapped_line_count(text)
    if not text or text == "" then
        return 1
    end

    local total = 0
    for _, line in ipairs(vim.split(text, "\n", { plain = true, trimempty = false })) do
        local display_width = vim.fn.strdisplaywidth(line)
        local segments = math.max(1, math.ceil(math.max(display_width, 1) / ASK_WINDOW_WIDTH))
        total = total + segments
    end

    return math.max(total, 1)
end

local function insert_soft_break(win)
    if not (win and win.win and win.buf and vim.api.nvim_buf_is_valid(win.buf)) then
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(win.win)
    local row = cursor[1] - 1
    local col = cursor[2]
    local current_line = vim.api.nvim_buf_get_lines(win.buf, row, row + 1, false)[1] or ""

    local before = col == 0 and "" or string.sub(current_line, 1, col)
    local after = string.sub(current_line, col + 1)

    vim.api.nvim_buf_set_lines(win.buf, row, row + 1, false, { before, after })
    vim.api.nvim_win_set_cursor(win.win, { row + 2, 0 })
    vim.bo[win.buf].modified = false
    win:update()
end

local function configure_ask_window_runtime()
    local ok, config = pcall(require, "opencode.config")
    if not ok then
        return
    end

    config.opts.ask = config.opts.ask or {}
    config.opts.ask.snacks = config.opts.ask.snacks or {}
    config.opts.ask.snacks.win = config.opts.ask.snacks.win or {}

    local win_opts = config.opts.ask.snacks.win
    win_opts.width = ASK_WINDOW_WIDTH
    win_opts.min_width = ASK_WINDOW_WIDTH
    win_opts.max_width = ASK_WINDOW_WIDTH
    win_opts.min_height = 1
    win_opts.max_height = math.max(3, math.floor(vim.o.lines * ASK_WINDOW_MAX_HEIGHT_RATIO))
    win_opts.height = function(win)
        local desired = compute_wrapped_line_count(win and win:text() or "")
        local max_height = math.max(3, math.floor(vim.o.lines * ASK_WINDOW_MAX_HEIGHT_RATIO))
        return math.max(1, math.min(desired, max_height))
    end

    win_opts.wo = vim.tbl_deep_extend("force", win_opts.wo or {}, {
        wrap = true,
        linebreak = true,
    })

    win_opts.actions = vim.tbl_deep_extend("force", win_opts.actions or {}, {
        insert_soft_break = insert_soft_break,
    })

    win_opts.keys = vim.tbl_deep_extend("force", win_opts.keys or {}, {
        soft_break_ctrl_enter = { "<C-CR>", "insert_soft_break", mode = { "i", "n" }, desc = "Insert newline" },
        soft_break_alt_enter = { "<M-CR>", "insert_soft_break", mode = { "i", "n" }, desc = "Insert newline" },
        soft_break_ctrl_j = { "<C-j>", "insert_soft_break", mode = { "i", "n" }, desc = "Insert newline" },
    })
end

local function safe_set_width(win, width)
    if not (win and vim.api.nvim_win_is_valid(win) and width) then
        return
    end
    pcall(vim.api.nvim_win_set_width, win, math.max(1, math.floor(width)))
end

local function find_opencode_terminal_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "opencode_terminal" then
            return win
        end
    end
end

local function opencode_terminal_is_open()
    return find_opencode_terminal_win() ~= nil
end

local function pick_primary_code_window(preferred_win)
    if preferred_win and vim.api.nvim_win_is_valid(preferred_win) then
        local preferred_buf = vim.api.nvim_win_get_buf(preferred_win)
        if vim.bo[preferred_buf].buftype ~= "terminal" then
            return preferred_win
        end
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype ~= "terminal" and vim.bo[buf].filetype ~= "opencode_terminal" then
            return win
        end
    end
end

local function apply_window_compaction(preferred_code_win)
    window_layout_state.terminals = {}

    local code_win = pick_primary_code_window(preferred_code_win)
    if code_win then
        local current_width = vim.api.nvim_win_get_width(code_win)
        window_layout_state.code = { win = code_win, width = current_width }
        if current_width > CODE_WINDOW_TARGET_WIDTH then
            safe_set_width(code_win, CODE_WINDOW_TARGET_WIDTH)
        end
    else
        window_layout_state.code = nil
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= code_win then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "terminal" and vim.bo[buf].filetype ~= "opencode_terminal" then
                local width = vim.api.nvim_win_get_width(win)
                table.insert(window_layout_state.terminals, { win = win, width = width })
                safe_set_width(win, math.min(width, TERMINAL_MIN_WIDTH))
            end
        end
    end
end

local function restore_window_layout()
    if window_layout_state.code and window_layout_state.code.win and window_layout_state.code.width then
        safe_set_width(window_layout_state.code.win, window_layout_state.code.width)
    end

    for _, entry in ipairs(window_layout_state.terminals) do
        if entry.win and entry.width then
            safe_set_width(entry.win, entry.width)
        end
    end

    window_layout_state.code = nil
    window_layout_state.terminals = {}
end

-- Configure global options
local function configure_globals()
    vim.g.opencode_opts = {
        provider = {
            enabled = "snacks",
            snacks = {
            },
        },
        ask = {
            snacks = {
                win = {
                    width = ASK_WINDOW_WIDTH,
                    min_width = ASK_WINDOW_WIDTH,
                    max_width = ASK_WINDOW_WIDTH,
                    wo = {
                        wrap = true,
                        linebreak = true,
                    },
                },
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
                    or type(client_mod) ~= "table" or type(client_mod.subscribe_to_sse) ~= "function" then
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
                            client_mod.subscribe_to_sse(port, function(event)
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
                                    local filePath = event.properties.part.state.input and
                                    event.properties.part.state.input.filePath
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
                if window_layout_state.code or #window_layout_state.terminals > 0 then
                    restore_window_layout()
                end
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
                -- vim.keymap.set("t", "<C-u>", function()
                --     require("opencode").command("session.half.page.up")
                -- end, { desc = "opencode half page up" })
                -- vim.keymap.set("t", "<C-d>", function()
                --     require("opencode").command("session.half.page.down")
                -- end, { desc = "opencode half page down" })
            end
        end,
    })
end

-- Setup user keymaps
local function setup_user_keymaps()
    -- Core opencode functionality keymaps
    local function focus_opencode_terminal()
        local opencode_win = find_opencode_terminal_win()
        if opencode_win then
            vim.api.nvim_set_current_win(opencode_win)
        end
    end

    local function ensure_opencode_open(trigger_win, opts)
        opts = opts or {}
        if opencode_terminal_is_open() then
            return true
        end

        require('opencode').toggle()

        vim.defer_fn(function()
            if not opencode_terminal_is_open() then
                return
            end

            apply_window_compaction(trigger_win)

            if opts.restore_focus and trigger_win and vim.api.nvim_win_is_valid(trigger_win) then
                vim.api.nvim_set_current_win(trigger_win)
            end
        end, 40)

        return false
    end

    -- Toggle opencode interface
    vim.keymap.set({ 'n' }, '<leader>ot', function()
        local trigger_win = vim.api.nvim_get_current_win()
        local was_open = opencode_terminal_is_open()

        require('opencode').toggle()

        vim.defer_fn(function()
            local is_open = opencode_terminal_is_open()
            if not was_open and is_open then
                apply_window_compaction(trigger_win)
            elseif was_open and not is_open then
                if window_layout_state.code or #window_layout_state.terminals > 0 then
                    restore_window_layout()
                end
            end

            if is_open then
                focus_opencode_terminal()
            end
        end, 40)
    end, { desc = 'Toggle opencode' })

    -- Opencode selection interface
    vim.keymap.set({ 'n', 'v' }, '<leader>fo', function()
        require('opencode').select()
    end, { desc = 'Find opencode command' })

    -- Ask opencode questions
    vim.keymap.set('n', '<leader>oA', function()
        local trigger_win = vim.api.nvim_get_current_win()
        ensure_opencode_open(trigger_win, { restore_focus = true })
        require('opencode').ask()
    end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n', 'v' }, '<leader>oa', function()
        local trigger_win = vim.api.nvim_get_current_win()
        ensure_opencode_open(trigger_win, { restore_focus = true })
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
    configure_ask_window_runtime()
    setup_auto_reload()
    setup_terminal_keymaps()
    setup_user_keymaps()
end

return M
