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

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format({ timeout_ms = 5000 })
end)

vim.keymap.set("n", "<c-n>", "<cmd>cnext<cr>zz")
vim.keymap.set("n", "<c-b>", "<cmd>cprev<cr>zz")
vim.keymap.set("n", "<leader>n", "<cmd>lnext<cr>zz")
vim.keymap.set("n", "<leader>b", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])
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
vim.keymap.set("n", "<C-c>", vim.cmd.CloseAll)
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>")

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


