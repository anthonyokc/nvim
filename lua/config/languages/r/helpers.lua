local M = {}

local api = vim.api
local map = vim.keymap
local levels = vim.log.levels

local cached_get_code_to_send

local function get_code_to_send_fn()
  if cached_get_code_to_send ~= nil then
    return cached_get_code_to_send or nil
  end

  if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" then
    cached_get_code_to_send = false
    return nil
  end

  local ok, send = pcall(require, "r.send")
  if not ok or type(send.line) ~= "function" then
    cached_get_code_to_send = false
    return nil
  end

  local idx = 1
  while true do
    local name, value = debug.getupvalue(send.line, idx)
    if not name then break end
    if name == "get_code_to_send" then
      cached_get_code_to_send = value
      return value
    end
    idx = idx + 1
  end

  cached_get_code_to_send = false
  return nil
end

local function is_boundary_line(line)
  return not line or line:match("^%s*$") or line:match("^%s*#")
end

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

-- Send paragraph to R (from current line to next blank line or comment)
-- This intentionally can run multiple adjacent separate commands
-- It can catch when the blank line is within a multi-line expression
-- and continue sending until a real boundary is found
local function legacy_send_paragraph()
  local start_line = vim.fn.line('.')
  local end_line = start_line
  local total_lines = vim.fn.line('$')

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

  vim.cmd('normal! ' .. start_line .. 'GV' .. end_line .. 'G')
  vim.fn.feedkeys(api.nvim_replace_termcodes('<Plug>RDSendSelection', true, true, true), 'n')
end

function M.send_paragraph_to_r()
  local get_code_fn = get_code_to_send_fn()
  local ok_send, send = pcall(require, "r.send")

  if not get_code_fn or not ok_send then
    legacy_send_paragraph()
    return
  end

  local total_lines = api.nvim_buf_line_count(0)
  local current_line = api.nvim_win_get_cursor(0)[1]

  while current_line <= total_lines do
    api.nvim_win_set_cursor(0, { current_line, 0 })

    local line_text = vim.fn.getline(current_line)
    local lines, end_row = get_code_fn(line_text, current_line)

    if not end_row or #lines == 0 then
      legacy_send_paragraph()
      return
    end

    local sent, err = pcall(send.line, "stay")
    if not sent then
      vim.notify(string.format("Sending expression failed: %s", err), levels.WARN)
      return
    end

    local next_line = end_row + 2

    if next_line > total_lines then
      api.nvim_win_set_cursor(0, { total_lines, 0 })
      break
    end

    local next_text = vim.fn.getline(next_line)
    if is_boundary_line(next_text) then
      api.nvim_win_set_cursor(0, { next_line, 0 })
      break
    end

    if next_line <= current_line then
      break
    end

    current_line = next_line
  end
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

local function build_view_command(expr)
  local config = require("r.config").get_config()
  local view_cfg = config.view_df or {}

  local n_lines = tonumber(view_cfg.n_lines) or -1
  local argmnts = string.format(", nrows = %d", n_lines)

  if view_cfg.open_fun and view_cfg.open_fun ~= "" then
    local custom = view_cfg.open_fun
    if custom:find("%(%)") then
      custom = custom:gsub("()", "(" .. expr .. ")")
    elseif custom:find("%%s") then
      custom = custom:gsub("%%s", expr)
    else
      custom = string.format("%s(%s)", custom, expr)
    end
    custom = custom:gsub("'", '"')
    custom = custom:gsub('"', '\\"')
    argmnts = argmnts .. ", R_df_viewer = '" .. custom .. "'"
  end

  if view_cfg.save_fun and view_cfg.save_fun ~= "" then
    argmnts = argmnts .. ", save_fun = " .. view_cfg.save_fun
  end

  return string.format("nvimcom:::nvim_viewobj(%s%s)", expr, argmnts)
end

local function view_expression(expr)
  local send = require("r.send")
  local cmd = build_view_command(expr)
  local ok, result = pcall(send.cmd, cmd)
  if not ok then
    vim.notify(string.format("Viewing %s failed: %s", expr, result), levels.WARN)
    return false
  elseif result == false then
    vim.notify("R is not ready to view objects.", levels.WARN)
    return false
  end
  return true
end

-- View the result stored in .Last.value (used after running a pipe chain)
function M.view_last_value()
  return view_expression(".Last.value")
end

-- Send the current pipe chain and open it in the configured data viewer
function M.send_chain_view()
  local send = require("r.send")
  local ok, err = pcall(send.chain)
  if not ok then
    vim.notify(string.format("Sending pipe chain failed: %s", err), levels.WARN)
    return
  end

  view_expression(".Last.value")
end

return M
