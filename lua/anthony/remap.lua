vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "T", "<cmd>retab<CR>")
vim.keymap.set("v", "T", "<cmd>retab<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

vim.keymap.set("x", "p", [["_dP]])                 -- when you paste over some text, keep the text in the vim clipboard

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]) -- copy selection to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]])          -- copy whole line to system clipboard
vim.keymap.set("n", "yay", "<cmd>%y+<CR>")          -- copy whole line to system clipboard

vim.keymap.set({ "n", "v" }, "D", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format({ timeout_ms = 5000 })
end)

vim.keymap.set("n", "<c-n>", "<cmd>cnext<cr>zz")
vim.keymap.set("n", "<c-b>", "<cmd>cprev<cr>zz")
vim.keymap.set("n", "<leader>n", "<cmd>lnext<cr>zz")
vim.keymap.set("n", "<leader>b", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>rh", [[:%s/read.csv("\(.*\)")/read_csv(here("data\/\1"))/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = false })

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/anthony/packer.lua<CR>");
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- Close all windows
vim.api.nvim_create_user_command('CloseAll', function()
    vim.cmd('qa')
end, { desc = 'Close all windows and NvimTree if open' })
vim.keymap.set("n", "<C-z>", vim.cmd.CloseAll)
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>")
vim.keymap.set("n", "<C-S>", "<cmd>wa<CR>")
vim.keymap.set("n", "<C-x>", "<cmd>q<CR>") -- close current window

-- Remap Ctrl + Z to undo in Insert mode
vim.api.nvim_set_keymap('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })
-- Remap Ctrl + Y to redo in Insert mode
vim.api.nvim_set_keymap('i', '<C-y>', '<C-o><C-r>', { noremap = true, silent = true })

-- select the last pasted text
vim.api.nvim_set_keymap('n', 'gV', '`[v`]', { noremap = true })
vim.api.nvim_set_keymap('n', 'g=', '`[v`]=', { noremap = true })

-- open new file in current buffer
vim.keymap.set("n", ",e", function()
    local current_dir = vim.fn.getcwd()               -- Save the current working directory
    local path = vim.fn.expand('%:p:h') .. '/'        -- Construct the path to the directory of the current file and append a slash
    vim.cmd('edit ' .. path)                          -- Open the new file in the specified path
    vim.cmd('cd ' .. vim.fn.fnameescape(current_dir)) -- Restore the original working directory
end)

-- See list of buffers
vim.keymap.set("n", "<leader>ls", "<cmd>ls<CR>")
-- See list of modified buffers
vim.keymap.set("n", "<leader>lm", "<cmd>ls!<CR>")


local comment_styles = { "#", "//", "--" } -- -- Define the comment styles

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
vim.keymap.set("n", "<leader>#", convert_top_to_inline_comments)
vim.keymap.set("v", "<leader>#", function()
  vim.cmd('ConvertComments')
end)

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
vim.keymap.set('n', '<leader>\'', switch_to_terminal, { noremap = true, silent = true })

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

vim.keymap.set('n', '<leader>ht', toggle_terminal_visibility, { noremap = true, silent = true })

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

vim.keymap.set("n", "<leader>tt", vim.cmd.TermToggle, { desc = "Toggle [T]erminal", silent = true })
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
vim.api.nvim_set_keymap('n', '<leader>tt', ':lua CreateListedTerminal()<CR>', { noremap = true, silent = true })

