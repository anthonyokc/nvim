-- r.lua: R language-specific settings
-- This file is loaded from init.lua to set up R-specific keymaps and functions
-- It also includes a custom fold expression for R headings
local M = {}
local levels = vim.log.levels

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

-- Toggle adding/removing `<name> <-` prefix for a pipe chain
M.toggle_assignment_current_object = function()
    local line = vim.api.nvim_get_current_line()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Try to remove `<name> <- <name>` or `<name> <- <name> |> ...`
    local indent, lhs, rhs, trailing_ws = line:match("^(%s*)([%w_%.]+)%s*<%-%s*(.-)(%s*)$")
    if lhs and rhs then
        local rhs_trim = vim.trim(rhs)
        local rhs_name, rest = rhs_trim:match("^([%w_%.]+)(%s*|>.*)$")
        if rhs_name and rest and rhs_name == lhs then
            vim.api.nvim_set_current_line(indent .. rhs_name .. rest .. trailing_ws)
            vim.api.nvim_win_set_cursor(0, { cursor_row, math.max(cursor_col - (#lhs + 4), 0) })
            return
        end

        if rhs_trim == lhs then
            vim.api.nvim_set_current_line(indent .. lhs .. trailing_ws)
            vim.api.nvim_win_set_cursor(0, { cursor_row, math.max(cursor_col - (#lhs + 4), 0) })
            return
        end
    end

    -- Add assignment when the line starts with `<name |> ...`
    local indent2, name, rest2 = line:match("^(%s*)([%w_%.]+)(%s*|>.*)$")
    if name and rest2 then
        vim.api.nvim_set_current_line(string.format("%s%s <- %s%s", indent2, name, name, rest2))
        vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col + #name + 4 })
        return
    end

    -- Add self-assignment for a bare object name.
    local indent3, bare_name, trailing_ws2 = line:match("^(%s*)([%w_%.]+)(%s*)$")
    if bare_name then
        vim.api.nvim_set_current_line(string.format("%s%s <- %s%s", indent3, bare_name, bare_name, trailing_ws2))
        vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col + #bare_name + 4 })
        return
    end

    print("No object or pipe chain found to toggle assignment.")
end

-- Toggle adding/removing a trailing native pipe (`|>`) on the current line
M.toggle_trailing_pipe_current_line = function()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local trailing_ws = line:match("%s*$") or ""
    local trimmed = line:sub(1, #line - #trailing_ws)

    if trimmed:sub(-2) == "|>" then
        local before = trimmed:sub(1, -3)
        before = before:gsub("%s+$", "")
        vim.api.nvim_set_current_line(before .. trailing_ws)
        local new_col = math.min(cursor_col, #before)
        vim.api.nvim_win_set_cursor(0, { cursor_row, new_col })
        return
    end

    local spacer = trimmed == "" and "" or " "
    local updated = trimmed .. spacer .. "|>"
    vim.api.nvim_set_current_line(updated .. trailing_ws)
    vim.api.nvim_win_set_cursor(0, { cursor_row, #updated })
end

local function extract_current_function_expr()
    local word = vim.fn.expand("<cword>")
    if type(word) == "string" then
        word = vim.trim(word)
        if word ~= "" and word:match("^[%w_:%.$@]+$") then
            return word
        end
    end

    local wide = vim.fn.expand("<cWORD>")
    if type(wide) ~= "string" then
        return ""
    end
    wide = vim.trim(wide)
    if wide == "" then
        return ""
    end
    wide = wide:gsub("^`", "")
    wide = wide:gsub("`$", "")
    wide = wide:gsub("%(.+$", "")
    wide = wide:gsub("[,;]+$", "")
    wide = vim.trim(wide)

    if wide == "" then
        return ""
    end

    local candidate = wide:match("([%w_:%.$@]+)$")
    if candidate and candidate ~= "" then
        return candidate
    end

    candidate = wide:match("^([%w_:%.$@]+)")
    if candidate and candidate ~= "" then
        return candidate
    end

    return ""
end

M.assign_defaults_current_function = function()
    local expr = extract_current_function_expr()
    if expr == "" then
        vim.notify("No function name under cursor.", levels.WARN, { title = "R defaults" })
        return
    end

    if not vim.g.R_Nvim_status or vim.g.R_Nvim_status < 7 then
        vim.notify("Start R (use :RStart) before assigning defaults.", levels.WARN, { title = "R defaults" })
        return
    end

    local send_ok, send_mod = pcall(require, "r.send")
    if not send_ok then
        vim.notify("r.send module is unavailable.", levels.ERROR, { title = "R defaults" })
        return
    end

    local command = string.format(
        [=[(function(expr){f<-tryCatch(eval(parse(text=expr),envir=.GlobalEnv),error=function(e)NULL);if(is.null(f))f<-tryCatch(eval(parse(text=expr),envir=parent.frame()),error=function(e)NULL);if(is.null(f)){message("Function not found: ",expr);return(invisible(FALSE))};if(!is.function(f)){message("Object is not a function: ",expr);return(invisible(FALSE))};d<-formals(f);if(length(d)==0){message("No defaults for: ",expr);return(invisible(TRUE))};e<-environment(f);if(is.null(e))e<-.GlobalEnv;a<-character(0);for(n in names(d)){v<-d[[n]];if(!(is.symbol(v)&&as.character(v)=="")){val<-tryCatch(eval(v,envir=e),error=function(err)structure(list(error=err),class="try-error"));if(!inherits(val,"try-error")){assign(n,val,envir=.GlobalEnv);a<-c(a,n)}}};if(length(a)==0)message("No defaults assigned for: ",expr)else message("Defaults assigned for ",expr,": ",paste(a,collapse=", "));invisible(TRUE)})(%q)]=],
        expr)

    local ok, result = pcall(send_mod.cmd, command)
    if not ok then
        vim.notify(string.format("Failed to assign defaults: %s", result), levels.ERROR, { title = "R defaults" })
    elseif result == false then
        vim.notify("R is not ready to receive commands.", levels.WARN, { title = "R defaults" })
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
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ra',
                ':lua require("config.languages.r").toggle_assignment_current_object()<CR>',
                { noremap = true, silent = true, desc = "Toggle pipe assignment" })
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>rp',
                ':lua require("config.languages.r").toggle_trailing_pipe_current_line()<CR>',
                { noremap = true, silent = true, desc = "Toggle trailing pipe" })
            -- Toggle R package prefixing
            vim.keymap.set('n', '<leader>rc', function()
                vim.g.blink_cmp_r_prefix_enabled = not vim.g.blink_cmp_r_prefix_enabled
                local status = vim.g.blink_cmp_r_prefix_enabled and 'enabled' or 'disabled'
                vim.notify('R package prefixing ' .. status, vim.log.levels.INFO)
            end, { desc = 'Toggle R package prefixing' })
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
