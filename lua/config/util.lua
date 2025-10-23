-- util.lua: General utility functions used for Neovim configuration
local M = {}

-- Function to save all buffers and create directories if needed
M.save_all_with_dirs = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        -- Skip if buffer isn't loaded
        if not vim.api.nvim_buf_is_loaded(buf) then
            goto continue
        end

        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        local name = vim.api.nvim_buf_get_name(buf)

        -- Skip if it's a special buffer (e.g. terminal) or unnamed
        if buftype == "" and name ~= "" then
            local directory = vim.fn.fnamemodify(name, ":h")
            vim.fn.mkdir(directory, "p") -- create directory if needed
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("write")         -- only valid on normal buffers
            end)
        end

        ::continue::
    end
end

-- Window size management
M.window_sizes = {}
M.toggle_window_size = function()
    local win_id = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(win_id)
    local total_width = vim.o.columns

    if not M.window_sizes[win_id] then
        -- Store current size if we haven't stored it yet
        M.window_sizes[win_id] = win_width

        -- Resize to 50% of screen width
        vim.api.nvim_win_set_width(win_id, math.floor(total_width * 0.5))
    else
        -- Restore original size
        vim.api.nvim_win_set_width(win_id, M.window_sizes[win_id])
        -- Clear stored size
        M.window_sizes[win_id] = nil
    end
end

-- Function to get the project root directory
M.root_dir = function(opts)
    opts                       = opts or {}
    local icon                 = opts.icon or "󱉭 "
    local mode                 = opts.mode or "name" -- "name" | "path" | "relative"
    local truncate             = opts.truncate       -- number of chars (optional)
    local markers              = opts.markers or { ".git", "pyproject.toml", "package.json", "go.mod", "Cargo.toml",
        ".hg", ".svn", "Makefile", ".root" }
    local use_cwd_if_not_found = opts.strict ~= true

    local function find_root()
        local file = vim.api.nvim_buf_get_name(0)
        local start = (file ~= "" and vim.fs.dirname(file)) or vim.loop.cwd()
        local hit = vim.fs.find(markers, { path = start, upward = true })[1]
        local dir = hit and vim.fs.dirname(hit) or (use_cwd_if_not_found and vim.loop.cwd()) or start
        -- add "/" to the end of dir to avoid edge cases
        return vim.fs.basename(dir), dir
    end

    local function file_from_root(root)
        local buf = vim.api.nvim_buf_get_name(0)
        if buf == "" then return nil end
        buf, root = vim.fs.normalize(buf), vim.fs.normalize(root)
        local rel = (vim.fs.relpath and vim.fs.relpath(buf, root))
            or (buf:sub(1, #root + 1) == (root .. "/") and buf:sub(#root + 2) or buf)
        return rel and rel:gsub("\\", "/") or nil
    end

    return function()
        local name, path = find_root()
        local text = (mode == "path" and path)
            or (mode == "relative" and vim.fn.fnamemodify(path, ":."))
            or name
        local rel = file_from_root(path)
        if mode == "file" then
            text = rel or vim.fs.basename(path)
        elseif mode == "file_dir" then
            if rel then
                local d = vim.fs.dirname(rel)
                text = (d and d ~= "." and d ~= "") and (d .. "/") or ""
            else
                text = ""
            end
        elseif mode == "file_base" then
            text = rel and vim.fs.basename(rel) or vim.fs.basename(path)
        elseif mode == "path" then
            text = path
        elseif mode == "relative" then
            text = vim.fn.fnamemodify(path, ":.")
        else
            text = name
        end
        local out = icon .. text
        if truncate and #out > truncate then out = vim.fn.strcharpart(out, 0, truncate - 1) .. "…" end
        return out
    end
end



-- Infer a single-line comment prefix for the current buffer
M.get_comment_prefix = function()
    local ft = vim.bo.filetype
    local map = {
        r = "#",
        rmd = "#",
        qmd = "#",
        quarto = "#",
        lua = "--",
        rust = "//",
        rs = "//",
        c = "//",
        h = "//",
        cpp = "//",
        cxx = "//",
        hpp = "//",
        hxx = "//",
        bash = "#",
        sh = "#",
        zsh = "#",
        fish = "#",
        go = "//",
        python = "#",
        py = "#",
    }

    if map[ft] then return map[ft] end

    local cs = vim.bo.commentstring or ""
    if cs ~= "" and cs:find("%%s") then
        local before = cs:match("^(.*)%%s") or ""
        local after = cs:match("%%s(.*)$") or ""
        before = before:gsub("%s+$", "")
        after = after:gsub("^%s+", "")
        if before ~= "" and after == "" then
            return before
        end
    end

    return "#"
end

local toggle_todo_line = function(suffix)
    suffix = suffix or ""
    local prefix = M.get_comment_prefix()
    local line = vim.api.nvim_get_current_line()
    local indent = line:match("^%s*") or ""
    local content = line:sub(#indent + 1)

    local suffix_part = (suffix ~= "" and (suffix .. " ")) or ""
    local todo_prefix = prefix .. " TODO: " .. suffix_part
    local comment_prefix = prefix .. " "

    if content:sub(1, #todo_prefix) == todo_prefix then
        -- Line starts with "<comment> TODO: ..." - remove just the TODO portion if needed
        local new_content = content:sub(#todo_prefix + 1)
        if new_content:match("^%s*$") then
            -- No text after TODO:, remove entire comment
            vim.api.nvim_set_current_line(indent .. new_content)
        else
            -- Text exists after TODO:, keep the comment prefix
            vim.api.nvim_set_current_line(indent .. comment_prefix .. new_content)
        end
    elseif content:sub(1, #comment_prefix) == comment_prefix then
        -- Line starts with just "<comment> " - add TODO:
        local new_content = content:sub(#comment_prefix + 1)
        vim.api.nvim_set_current_line(indent .. todo_prefix .. new_content)
    else
        -- Line doesn't start with comment - add full TODO: comment
        vim.api.nvim_set_current_line(indent .. todo_prefix .. content)
    end
end

local comment_selection_with_todo = function(suffix)
    suffix = suffix or ""
    local prefix = M.get_comment_prefix()
    local todo_line = prefix .. " TODO:"
    if suffix ~= "" then
        todo_line = todo_line .. " " .. suffix
    end

    local buf = 0
    local start_mark = vim.api.nvim_buf_get_mark(buf, "<")
    local end_mark = vim.api.nvim_buf_get_mark(buf, ">")
    if not start_mark or not end_mark then return end

    local start_line = math.min(start_mark[1], end_mark[1]) - 1
    local end_line = math.max(start_mark[1], end_mark[1]) - 1
    if start_line < 0 or end_line < start_line then return end

    local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line + 1, false)
    if #lines == 0 then return end

    local first_indent = lines[1]:match("^%s*") or ""
    local comment_prefix = prefix .. " "

    for idx, line in ipairs(lines) do
        local indent = line:match("^%s*") or ""
        local remainder = line:sub(#indent + 1)
        if remainder == "" then
            lines[idx] = indent .. comment_prefix
        else
            lines[idx] = indent .. comment_prefix .. remainder
        end
    end

    table.insert(lines, 1, first_indent .. todo_line)
    vim.api.nvim_buf_set_lines(buf, start_line, end_line + 1, false, lines)

    -- Leave visual mode cleanly
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

-- Toggle "<comment> TODO: " at the start of the current line (preserves indent)
M.toggle_todo_current_line = function()
    toggle_todo_line()
end

M.toggle_todo_consider_deleting = function(mode)
    mode = mode or vim.fn.mode()
    if mode == "n" then
        toggle_todo_line("🗑️ Consider deleting")
    elseif mode == "v" or mode == "V" or mode == "\22" then
        comment_selection_with_todo("🗑️ Consider deleting")
    else
        toggle_todo_line("🗑️ Consider deleting")
    end
end

return M
