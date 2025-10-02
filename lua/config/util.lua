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

-- Toggle "<comment> TODO: " at the start of the current line (preserves indent)
M.toggle_todo_current_line = function()
    local prefix = M.get_comment_prefix()
    local line = vim.api.nvim_get_current_line()
    local indent = line:match("^%s*") or ""
    local content = line:sub(#indent + 1)

    local todo_prefix = prefix .. " TODO: "
    local comment_prefix = prefix .. " "

    if content:sub(1, #todo_prefix) == todo_prefix then
        -- Line starts with "<comment> TODO: " - remove just "TODO: " if there's text after it
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

return M
