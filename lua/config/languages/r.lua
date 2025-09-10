-- r.lua: R language-specific settings
-- This file is loaded from init.lua to set up R-specific keymaps and functions
-- It also includes a custom fold expression for R headings
local M = {}

-- Function to reformat R function calls
local function reformat_r_function(mode)
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
M.format_r_function = function()
    reformat_r_function("format")
end

M.unformat_r_function = function()
    reformat_r_function("unformat")
end

-- Function to toggle comment on selected lines
M.toggle_comment_selected_lines = function()
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
M.toggle_comment_current_line = function()
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

-- Setup function to be called from init.lua
M.setup = function()
    -- Set up R-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "r", "rmd", "quarto" },
        callback = function()
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>C',
                ':lua require("config.lang.r").toggle_comment_current_line()<CR>',
                { noremap = true, silent = true, desc = "Toggle comment" })
            vim.api.nvim_buf_set_keymap(0, 'v', '<leader>C',
                ':lua require("config.lang.r").toggle_comment_selected_lines()<CR>',
                { noremap = true, silent = true, desc = "Toggle comment" })
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>rf', ':lua require("config.lang.r").format_r_function()<CR>',
                { noremap = true, silent = true, desc = "Format R function" })
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ru', ':lua require("config.lang.r").unformat_r_function()<CR>',
                { noremap = true, silent = true, desc = "Unformat R function" })
        end
    })
end

-- lua/my/folds_r.lua
if not _G.R_heading_fold then
    function _G.R_heading_fold(lnum)
        local s = vim.fn.getline(lnum)
        if s:match("^%s*###%s") then return ">3" end
        if s:match("^%s*##%s") then return ">2" end
        if s:match("^%s*#%s") then return ">1" end
        for i = lnum - 1, 1, -1 do
            local p = vim.fn.getline(i)
            if p:match("^%s*###%s") then return 4 end
            if p:match("^%s*##%s") then return 3 end
            if p:match("^%s*#%s") then return 2 end
        end
        return 0
    end
end


local grp = vim.api.nvim_create_augroup("RHeadingFolds", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
    group = grp,
    callback = function(ev)
        if vim.bo[ev.buf].filetype ~= "r" then return end
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_option_value("foldenable", true, { win = win })
        vim.api.nvim_set_option_value("foldmethod", "expr", { win = win })
        vim.api.nvim_set_option_value("foldexpr", "v:lua.R_heading_fold(v:lnum)", { win = win })
        vim.api.nvim_set_option_value("foldlevel", 99, { win = win })
        vim.api.nvim_set_option_value("foldignore", "", { win = win })
    end,
})

return M

