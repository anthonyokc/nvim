require("anthony.remap")
require("anthony.set")
require("anthony.lazy_init")

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

local augroup = vim.api.nvim_create_augroup
local AnthonyGroup = augroup('AnthonyGroup', {})

local yank_group = augroup('HighlightYank', {})

local autocmd = vim.api.nvim_create_autocmd

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = AnthonyGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = AnthonyGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

autocmd('BufEnter', {
    pattern = '*.txt',
    callback = function()
        if vim.bo.filetype == 'help' then
            vim.cmd('wincmd T')
            vim.cmd('AerialToggle!')
        end
    end,
})

-- Open nvim-tree when entering a directory


vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

local in_wsl = os.getenv('WSL_DISTRO_NAME') ~= nil

if in_wsl then
    vim.g.clipboard = {
        name = 'wsl clipboard',
        copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
        paste = { ["+"] = { "nvim_paste" }, ["*"] = { "nvim_paste" } },
        cache_enabled = true
    }
end


vim.cmd [[
    hi NvimTreeNormal guibg=NONE ctermbg=NONE
]]

local function ReformatRFunction(mode)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1 -- API uses 0-based indexing for rows

    local function find_matching_paren(lines, start_row, start_col)
        local paren_count = 1
        for r = start_row, #lines do
            local line = lines[r]
            local c = (r == start_row) and start_col or 1
            while c <= #line do
                if line:sub(c, c) == "(" then
                    paren_count = paren_count + 1
                elseif line:sub(c, c) == ")" then
                    paren_count = paren_count - 1
                    if paren_count == 0 then
                        return r, c
                    end
                end
                c = c + 1
            end
        end
        return nil, nil
    end

    local lines = vim.api.nvim_buf_get_lines(0, row, -1, false)
    local line = lines[1]

    -- Split the line into prefix and function call
    local prefix, func_call = line:match("^(.-)([%w_]+%s*%(.*)")
    if not func_call then
        print("No function call found on this line.")
        return
    end

    local func_name = func_call:match("^([%w_]+)")
    local open_paren = func_call:find("%(")
    if not open_paren then
        print("No opening parenthesis found.")
        return
    end

    -- Find the matching closing parenthesis
    local end_row, end_col = find_matching_paren(lines, 1, #prefix + open_paren)
    if not end_row then
        print("No matching closing parenthesis found.")
        return
    end

    local full_func_call = table.concat(lines, "\n"):sub(#prefix + 1, end_col + (end_row - 1) * #line)
    local args = full_func_call:match("%b()")

    if func_name and args then
        if mode == "format" then
            args = args:sub(2, -2) -- Remove outer parentheses
            local split_args = {}
            local nested_count = 0
            local current_arg = ""

            for c in args:gmatch(".") do
                if c == "(" then
                    nested_count = nested_count + 1
                elseif c == ")" then
                    nested_count = nested_count - 1
                end

                if c == "," and nested_count == 0 then
                    table.insert(split_args, current_arg:match("^%s*(.-)%s*$"))
                    current_arg = ""
                else
                    current_arg = current_arg .. c
                end
            end
            if current_arg ~= "" then
                table.insert(split_args, current_arg:match("^%s*(.-)%s*$"))
            end

            local indent = prefix:match("^%s*")
            local arg_indent = indent .. "  "

            local new_lines = {}
            table.insert(new_lines, prefix .. func_name .. "(")
            for i, arg in ipairs(split_args) do
                table.insert(new_lines, arg_indent .. arg .. (i < #split_args and "," or ""))
            end
            table.insert(new_lines, indent .. ")" .. lines[end_row]:sub(end_col + 1))

            vim.api.nvim_buf_set_lines(0, row, row + end_row, false, new_lines)
        elseif mode == "unformat" then
            local unformatted = prefix .. full_func_call:gsub("\n%s*", " ")
            vim.api.nvim_buf_set_lines(0, row, row + end_row, false, { unformatted .. lines[end_row]:sub(end_col + 1) })
        end
    else
        print("No function found under cursor.")
    end
end

-- Function to format R function
function FormatRFunction()
    ReformatRFunction("format")
end

function UnformatRFunction()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1 -- API uses 0-based indexing for rows

    local function find_matching_paren(lines, start_row, start_col)
        local paren_count = 1
        for r = start_row, #lines do
            local line = lines[r]
            local c = (r == start_row) and start_col or 1
            while c <= #line do
                if line:sub(c, c) == "(" then
                    paren_count = paren_count + 1
                elseif line:sub(c, c) == ")" then
                    paren_count = paren_count - 1
                    if paren_count == 0 then
                        return r, c
                    end
                end
                c = c + 1
            end
        end
        return nil, nil
    end

    local lines = vim.api.nvim_buf_get_lines(0, row, -1, false)
    local line = lines[1]

    -- Split the line into prefix and function call
    local prefix, func_call = line:match("^(.-)([%w_]+%s*%(.*)")
    if not func_call then
        print("No function call found on this line.")
        return
    end

    local func_name = func_call:match("^([%w_]+)")
    local open_paren = func_call:find("%(")
    if not open_paren then
        print("No opening parenthesis found.")
        return
    end

    -- Find the matching closing parenthesis
    local end_row, end_col = find_matching_paren(lines, 1, #prefix + open_paren)
    if not end_row then
        print("No matching closing parenthesis found.")
        return
    end

    local full_func_call = table.concat(lines, "\n"):sub(#prefix + 1, end_col + (end_row - 1) * #line)
    local args = full_func_call:match("%b()")

    if func_name and args then
        local unformatted = prefix .. full_func_call:gsub("\n%s*", " ")
        vim.api.nvim_buf_set_lines(0, row, row + end_row, false, { unformatted .. lines[end_row]:sub(end_col + 1) })
    else
        print("No function found under cursor.")
    end
end

-- Function to toggle comment on selected lines
function toggle_comment_selected_lines()
    -- Get the start and end positions of the selection
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")

    -- Loop through the selected lines
    for line_num = start_line, end_line do
        -- Get the content of the current line
        local line_content = vim.fn.getline(line_num)
        -- Check if the line starts with "# "
        if string.sub(line_content, 1, 2) == "# " then
            -- Remove "# " from the beginning of the line
            local new_line_content = string.sub(line_content, 3)
            vim.fn.setline(line_num, new_line_content)
        else
            -- Prepend "# " to the line content
            local new_line_content = "# " .. line_content
            vim.fn.setline(line_num, new_line_content)
        end
    end
end

-- Function to toggle comment on the current line
function toggle_comment_current_line()
    -- Get the current line number
    local line_num = vim.fn.line(".")
    -- Get the content of the current line
    local line_content = vim.fn.getline(line_num)
    -- Check if the line starts with "# "
    if string.sub(line_content, 1, 2) == "# " then
        -- Remove "# " from the beginning of the line
        local new_line_content = string.sub(line_content, 3)
        vim.fn.setline(line_num, new_line_content)
    else
        -- Prepend "# " to the line content
        local new_line_content = "# " .. line_content
        vim.fn.setline(line_num, new_line_content)
    end
end

vim.api.nvim_set_keymap('n', '<leader>C', ':lua toggle_comment_current_line()<CR>',
    { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>C', ':lua toggle_comment_selected_lines()<CR>',
    { noremap = true, silent = true })
