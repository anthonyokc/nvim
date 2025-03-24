-- General utility functions
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
      vim.fn.mkdir(directory, "p")               -- create directory if needed
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("write")                        -- only valid on normal buffers
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

return M 