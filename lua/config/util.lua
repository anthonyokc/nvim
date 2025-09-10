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



return M
