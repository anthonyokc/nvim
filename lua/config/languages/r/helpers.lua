local M = {}

local api = vim.api
local map = vim.keymap

-- Helper to set buffer-local keymaps with descriptions
function M.bufmap(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts = vim.tbl_extend("force", { buffer = 0, silent = true, desc = desc }, opts)
  map.set(mode, lhs, rhs, opts)
end

-- Helper to create R command functions
function M.r_cmd(code)
  return function()
    require("r.send").cmd(code)
  end
end

-- Helper to create R action functions
function M.r_action(expr)
  return function()
    require("r.run").action(expr)
  end
end

-- Clear mappings that start with a prefix
function M.clear_prefix_mappings(prefix, modes)
  modes = modes or { "n", "i", "v", "c" }
  for _, mode in ipairs(modes) do
    for _, mapping in ipairs(api.nvim_get_keymap(mode)) do
      local lhs = mapping.lhs or ""
      if vim.startswith(lhs, prefix) then
        pcall(api.nvim_del_keymap, mode, lhs)
      end
    end
  end
end

-- Replace write_csv(obj, here("path")) with read_csv(here("path"))
function M.read_csv_to_object()
  local start_line, end_line = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]
  local lines = api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  
  for i, line in ipairs(lines) do
    local object_name, file_path = line:match('write_csv%(([%w_]+),%s*here%("(.+)"%)%)')
    if object_name and file_path then
      lines[i] = string.format('%s <- read_csv(here("%s"))', object_name, file_path)
    end
  end
  
  api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Send paragraph to R (from current line to next blank line)
function M.send_paragraph_to_r()
  local start_line = vim.fn.line('.')
  local end_line = start_line
  local total_lines = vim.fn.line('$')
  
  -- Find the next blank line or end of file
  for i = start_line + 1, total_lines do
    local line = vim.fn.getline(i)
    if line:match('^%s*$') then
      end_line = i - 1
      break
    end
    if i == total_lines then
      end_line = i
    end
  end
  
  -- Send the range
  vim.cmd('normal! ' .. start_line .. 'GV' .. end_line .. 'G')
  vim.fn.feedkeys(api.nvim_replace_termcodes('<Plug>RDSendSelection', true, true, true), 'n')
end

-- Send the current pipe chain and inspect the result with glimpse()
function M.send_chain_glimpse()
  local glimpse_fn = vim.g.r_chain_glimpse_fn or "dplyr::glimpse"

  local send = require("r.send")
  local ok, err = pcall(send.chain)
  if not ok then
    vim.notify(string.format("Sending pipe chain failed: %s", err), vim.log.levels.WARN)
    return
  end

  local cmd = string.format("%s(.Last.value)", glimpse_fn)
  local send_ok, send_result = pcall(send.cmd, cmd)
  if not send_ok then
    vim.notify(string.format("glimpse() failed: %s", send_result), vim.log.levels.WARN)
  elseif send_result == false then
    local msg = "R is not ready"
    vim.notify(string.format("glimpse() failed: %s", msg), vim.log.levels.WARN)
  end
end

return M
