-- keymap.lua: Key mappings for Neovim
-- Primarily for mapping custom keybindings of native vim functions
-- or custom self-made functions

-- # Custom Keybindings of Native Vim Functions
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })

vim.keymap.set("n", "T", "<cmd>retab<CR>")
vim.keymap.set("v", "T", "<cmd>retab<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "p", [["_dP]])                                                           -- when you paste over some text, keep the text in the vim clipboard

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })    -- copy selection to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })        -- copy whole line to system clipboard
vim.keymap.set("n", "yay", "<cmd>%y+<CR>", { desc = "Copy whole file to system clipboard" }) -- copy whole line to system clipboard

vim.keymap.set({ "n", "v" }, "D", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format({ timeout_ms = 5000 })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>g", "gqap", { desc = "Format paragraph" })
vim.keymap.set("v", "<leader>g", "gqa", { desc = "Format selection" })
vim.keymap.set("x", "<leader>g", "gqa", { desc = "Format selection" })

vim.keymap.set("n", "<c-n>", "<cmd>cnext<cr>zz")
vim.keymap.set("n", "<c-b>", "<cmd>cprev<cr>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]],
    { desc = "Search and replace current word" })
vim.keymap.set("n", "<leader>rh", [[:%s/read.csv("\(.*\)")/read_csv(here("data\/\1"))/gI<Left><Left><Left>]],
    { desc = "Convert read.csv to read_csv with here()" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = false })
vim.keymap.set("n", "<leader>hx", "<cmd>%!xxd<CR>", { silent = false })


vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/anthony/packer.lua<CR>",
    { desc = "Edit packer.lua" });
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

-- source current file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so") --
end)

-- Close all windows
vim.api.nvim_create_user_command('CloseAll', function()
    -- Check for modified buffers before attempting to quit
    local modified_buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'modified') then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            table.insert(modified_buffers, buf_name ~= '' and buf_name or '[No Name]')
        end
    end
    
    if #modified_buffers > 0 then
        local message = "Unsaved changes in: " .. table.concat(modified_buffers, ', ')
        vim.notify(message, vim.log.levels.WARN)
        local choice = vim.fn.confirm('Unsaved changes detected. What would you like to do?', '&Save and Quit\n&Quit without Saving\n&Cancel', 1)
        if choice == 1 then
            -- Save all buffers and quit
            vim.cmd('wa')
            vim.cmd('qa')
        elseif choice == 2 then
            -- Quit without saving
            vim.cmd('qa!')
        end
        -- choice == 3 means cancel, do nothing
    else
        vim.cmd('qa')
    end
end, { desc = 'Close all windows and NvimTree if open' })
vim.keymap.set("n", "<C-z>", function()
    local ok, err = pcall(vim.cmd.CloseAll)
    if not ok then
        vim.notify("Failed to close all windows: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "Close all windows safely" })
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>")     -- save current buffer
vim.keymap.set("n", "<C-S>", "<cmd>wa<CR>")    -- save all buffers
vim.keymap.set("n", "<C-x>", "<cmd>q<CR>")     -- close current window

-- Remap Ctrl + Z to undo in Insert mode
vim.api.nvim_set_keymap('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })
-- Remap Ctrl + Y to redo in Insert mode
vim.api.nvim_set_keymap('i', '<C-y>', '<C-o><C-r>', { noremap = true, silent = true })

-- Remap case conversion commands for normal, visual, and visual block modes
vim.keymap.set("n", "<leader>su", "vu", { noremap = true, desc = "Convert to lowercase (normal)" })
vim.keymap.set("n", "<leader>sU", "vU", { noremap = true, desc = "Convert to uppercase (normal)" })
vim.keymap.set("n", "<leader>s~", "v~", { noremap = true, desc = "Toggle case (normal)" })

-- Visual mode case conversion
vim.keymap.set("x", "<leader>su", "u", { noremap = true, desc = "Convert to lowercase (visual)" })
vim.keymap.set("x", "<leader>sU", "U", { noremap = true, desc = "Convert to uppercase (visual)" })
vim.keymap.set("x", "<leader>s~", "~", { noremap = true, desc = "Toggle case (visual)" })

-- Disable the default case conversion bindings in normal mode
vim.keymap.set("n", "u", "u", { noremap = true, desc = "Undo" })         -- Keep u as undo only
vim.keymap.set("n", "U", "<nop>", { noremap = true, desc = "Disabled" }) -- Disable U completely

-- Disable the default case conversion bindings in visual mode
vim.keymap.set("x", "u", "<nop>", { noremap = true, desc = "Disabled" })
vim.keymap.set("x", "U", "<nop>", { noremap = true, desc = "Disabled" })


-- select the last pasted text
vim.api.nvim_set_keymap('n', 'gV', '`[v`]', { noremap = true })
vim.api.nvim_set_keymap('n', 'g=', '`[v`]=', { noremap = true })

-- See list of buffers
vim.keymap.set("n", "<leader>ls", "<cmd>ls<CR>", { desc = "List buffers" })
-- See list of modified buffers
vim.keymap.set("n", "<leader>lm", "<cmd>ls!<CR>", { desc = "List modified buffers" })

local comment_styles = { "#", "//", "--" } -- -- Define the comment styles

-- # Custom Keybindings of Self-Made Functions

-- Function to convert top line comments to inline comments
local function convert_top_to_inline_comments()
    -- Determine the mode: normal or visual
    local mode = vim.fn.mode()

    -- Get the current line or the selected lines in visual mode
    local start_line, end_line
    if mode == 'v' or mode == 'V' then
        start_line = vim.fn.line("'<")
        end_line = vim.fn.line("'>")
    else
        start_line = vim.fn.line('.')
        end_line = start_line
    end

    for line_number = start_line, end_line do
        local current_line = vim.fn.getline(line_number)

        -- Iterate over the comment styles and perform the conversion if a match is found
        for _, comment in ipairs(comment_styles) do
            -- Check if the line starts with a comment
            if current_line:match("^%s*" .. comment) then
                -- Extract the comment part
                local comment_part = current_line:match("^%s*" .. comment .. "%s*(.*)")

                -- Get the line below the current line
                local next_line_number = line_number + 1
                local next_line = vim.fn.getline(next_line_number)

                -- Create the new line with the inline comment

                local new_line = next_line .. " " .. " " .. comment_part
                -- Replace the next line with the new line
                vim.fn.setline(next_line_number, new_line)

                -- Delete the current line (original comment line)
                vim.fn.setline(line_number, '')
                break
            end
        end
    end
end

-- Create a custom command to run the conversion function
vim.api.nvim_create_user_command('ConvertComments', convert_top_to_inline_comments, {})

-- Bind the function to the shortcut key (leader #) in normal and visual mode
vim.keymap.set("n", "<leader>#", convert_top_to_inline_comments, { desc = "Convert top line comments to inline" })
vim.keymap.set("v", "<leader>#", function()
    vim.cmd('ConvertComments')
end, { desc = "Convert top line comments to inline" })

-- Switch between terminal buffer and the leftmost pane
local function switch_to_terminal()
    -- Save the current window ID
    local current_win = vim.api.nvim_get_current_win()

    -- Check if the current window is the terminal buffer
    if vim.bo.buftype == 'terminal' then
        -- Move to the leftmost window
        vim.cmd('wincmd t')
    else
        -- Find the terminal buffer window and switch to it
        local term_win = -1
        for win = 1, vim.fn.winnr('$') do
            if vim.fn.getbufvar(vim.fn.winbufnr(win), '&buftype') == 'terminal' then
                term_win = win
                break
            end
        end
        if term_win > 0 then
            vim.cmd(term_win .. 'wincmd w')
        end
    end
end

-- Map <leader>' to the switch_to_terminal function
vim.keymap.set('n', '<leader>\'', switch_to_terminal, { noremap = true, silent = true, desc = "Switch to terminal" })

-- Toggle terminal window visibility
local function toggle_terminal_visibility()
    local term_win = -1
    local term_buf = -1

    -- Find the terminal buffer and window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
            term_win = win
            term_buf = buf
            break
        end
    end

    if term_win ~= -1 then
        -- Terminal window exists, toggle its visibility
        if vim.api.nvim_win_is_valid(term_win) then
            -- Hide the terminal window
            vim.api.nvim_win_hide(term_win)
        else
            -- Show the terminal window
            vim.api.nvim_open_win(term_buf, true, {
                relative = 'editor',
                row = vim.o.lines - 15,
                col = 0,
                width = vim.o.columns,
                height = 15,
                style = 'minimal'
            })
        end
    else
        -- No terminal window found, create a new one
        vim.cmd('botright 15split | terminal')
    end
end

vim.keymap.set('n', '<leader>ht', toggle_terminal_visibility,
    { noremap = true, silent = true, desc = "Toggle terminal visibility" })

vim.api.nvim_create_user_command("TermToggle", function()
    local is_open = vim.g.term_win_id ~= nil and vim.api.nvim_win_is_valid(vim.g.term_win_id)

    if is_open then
        vim.api.nvim_win_hide(vim.g.term_win_id)
        vim.g.term_win_id = nil
        return
    end

    -- Open new window 25 lines tall at the bottom of the screen
    vim.cmd("botright 25 new")
    vim.g.term_win_id = vim.api.nvim_get_current_win()

    local has_term_buf = vim.g.term_buf_id ~= nil and vim.api.nvim_buf_is_valid(vim.g.term_buf_id)

    if has_term_buf then
        vim.api.nvim_win_set_buf(vim.g.term_win_id, vim.g.term_buf_id)
    else
        vim.cmd.term()
        vim.g.term_buf_id = vim.api.nvim_get_current_buf()
    end

    vim.cmd.startinsert()
end, {})

-- For session manager usage
vim.api.nvim_create_user_command("TermKill", function()
    if vim.g.term_win_id ~= nil then
        vim.api.nvim_win_close(vim.g.term_win_id, true)
        vim.g.term_win_id = nil
    end
    if vim.g.term_buf_id ~= nil then
        vim.api.nvim_buf_delete(vim.g.term_buf_id, { force = true })
        vim.g.term_buf_id = nil
    end
end, {})

vim.keymap.set("n", "<leader>tt", vim.cmd.TermToggle, { desc = "Toggle terminal", silent = true })
vim.keymap.set("t", "<C-t>", vim.cmd.TermToggle, { desc = "Toggle [^][T]erminal", silent = true })


-- Function to list all windows across all tabpages
function ListAllWindows()
    print("Listing all windows across all tabpages:")
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local tab_number = vim.api.nvim_tabpage_get_number(tab)
        print(string.format("Tabpage #%d:", tab_number))

        local windows = vim.api.nvim_tabpage_list_wins(tab)
        for _, win in ipairs(windows) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            local is_current = (win == vim.api.nvim_get_current_win()) and " (Current)" or ""
            print(string.format("  Window ID: %d, Buffer: %s%s", win, buf_name, is_current))
        end
    end
end

-- Create a user command to invoke the function
vim.api.nvim_create_user_command('ListAllWindows', ListAllWindows, {})


-- Function to create a listed terminal buffer
function CreateListedTerminal()
    -- Open a new split with a terminal
    vim.cmd('split')
    vim.cmd('terminal')

    -- Get the current buffer
    local bufnr = vim.api.nvim_get_current_buf()

    -- Set 'buflisted' to true
    vim.api.nvim_buf_set_option(bufnr, 'buflisted', true)
end

-- Keybinding to create a listed terminal
vim.keymap.set("n", "<leader>tt", vim.cmd.TermToggle, { desc = "Toggle terminal", silent = true })
vim.keymap.set("t", "<C-t>", vim.cmd.TermToggle, { desc = "Toggle [^][T]erminal", silent = true })

-- For plugins to lazy load on keypress
vim.keymap.set("n", "<leader>a", "<cmd>AvanteToggle<CR>", { desc = "Open Avante" })
vim.keymap.set("n", "<leader>ae", "<cmd>AvanteEdit<CR>", { desc = "Open Avante Edit" })
vim.keymap.set("n", "<leader>an", "<cmd>AvanteChatNew<CR>", { desc = "New Avante Chat" })

-- Function to reload a module (for development purposes)
-- Usage: R("config") to reload the config module
function R(name)
    require("plenary.reload").reload_module(name)
end


vim.g.tofu_provider_source  = vim.g.tofu_provider_source  or "opentofu/google"
vim.g.tofu_provider_version = vim.g.tofu_provider_version or "latest"  -- "latest" also works

function tofu_open_docs()
  -- try to auto-detect provider source/version from required_providers (only if not set)
  if not vim.g.tofu_autodetected then
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      for _, l in ipairs(vim.api.nvim_buf_get_lines(b, 0, -1, false)) do
        local src = l:match('%f[%w]source%s*=%s*"([^"]+)"')
        if src and src:find("/") then vim.g.tofu_provider_source = src end
        local ver = l:match('%f[%w]version%s*=%s*"([%d%p]+)"')
        if ver then
          vim.g.tofu_provider_version = ver:match("^v") and ver or ("v" .. ver)
        end
      end
    end
    vim.g.tofu_autodetected = true
  end

  local src = vim.g.tofu_provider_source or "opentofu/google"
  local ver = vim.g.tofu_provider_version or "latest"
  if ver:match("^%d") then ver = "v" .. ver end

  local base = ("https://search.opentofu.org/provider/%s/%s/docs/"):format(src, ver)
  local open = (vim.fn.has("mac") == 1 and "open")
            or (vim.loop.os_uname().sysname == "Windows_NT" and "start")
            or "xdg-open"

  local word = vim.fn.expand("<cword>")
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local buf = 0

  -- Look upward a bit to find the block header the cursor is inside.
  local kind, type_str
  for i = row, math.max(1, row - 40), -1 do
    local ln = vim.api.nvim_buf_get_lines(buf, i-1, i, false)[1]
    local r = ln:match('^%s*resource%s+"([^"]+)"')
    if r then kind, type_str = "resource", r; break end
    local d = ln:match('^%s*data%s+"([^"]+)"')
    if d then kind, type_str = "data", d; break end
  end

  local url
  if kind == "resource" then
    -- resources drop the provider prefix: google_organization_policy -> organization_policy
    url = base .. "resources/" .. type_str
  elseif kind == "data" then
    -- datasources also drop prefix: google_folder_iam_policy -> folder_iam_policy
    url = base .. "datasources/" .. type_str
  elseif vim.api.nvim_get_current_line():find(word .. "%s*%(") then
    -- function call on this line: name_from_id(...)
    url = base .. "functions/" .. word
  else
    -- fallback: open a guide using the full identifier (keeps provider prefix)
    url = base .. "guides/" .. word
  end

  vim.fn.jobstart({open, url}, {detach = true})
end

vim.keymap.set("n", "<leader>to", tofu_open_docs, {desc = "Hover or open OpenTofu docs" })

-- Toggle TODO at start of current line, language-aware
vim.keymap.set("n", "<leader>td", function()
    require("config.util").toggle_todo_current_line()
end, { desc = "Toggle TODO on current line" })

vim.keymap.set({ "n", "x" }, "<leader>tD", function()
    require("config.util").toggle_todo_consider_deleting()
end, { desc = "TODO consider deleting" })
