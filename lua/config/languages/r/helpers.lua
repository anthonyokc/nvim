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

local function get_visual_selection_lines()
  local mode = vim.fn.mode()
  local start_pos
  local end_pos

  if mode == "v" or mode == "V" or mode == "\022" then
    start_pos = vim.fn.getpos("v")
    end_pos = vim.fn.getpos(".")
    start_pos = { start_pos[2], start_pos[3] - 1 }
    end_pos = { end_pos[2], end_pos[3] - 1 }
  else
    start_pos = api.nvim_buf_get_mark(0, "<")
    end_pos = api.nvim_buf_get_mark(0, ">")
  end

  if not start_pos or not end_pos then
    return nil, nil
  end

  if start_pos[1] > end_pos[1] or (start_pos[1] == end_pos[1] and start_pos[2] > end_pos[2]) then
    start_pos, end_pos = end_pos, start_pos
  end

  local lines = api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], true)
  local vmode = mode == "n" and vim.fn.visualmode() or mode

  if vmode == "\022" then
    local start_col = start_pos[2] + 1
    local end_col = end_pos[2] + 1
    if start_col > end_col then
      start_col, end_col = end_col, start_col
    end
    for idx, line in ipairs(lines) do
      lines[idx] = string.sub(line, start_col, end_col)
    end
  elseif vmode == "v" then
    if start_pos[1] == end_pos[1] then
      lines[1] = string.sub(lines[1], start_pos[2] + 1, end_pos[2] + 1)
    else
      lines[1] = string.sub(lines[1], start_pos[2] + 1, -1)
      lines[#lines] = string.sub(lines[#lines], 1, end_pos[2] + 1)
    end
  end

  return lines, end_pos
end

local function get_quarto_r_expression()
  local line_num = api.nvim_win_get_cursor(0)[1]
  local line = vim.fn.getline(line_num)
  if line:match("^%s*$") then
    return nil
  end

  local chunk = require("r.chunk").get_current_code_chunk(0)
  if vim.tbl_isempty(chunk) or chunk:get_chunk_section_at_cursor() ~= "chunk_body" then
    return nil
  end

  local chunk_content = chunk:get_content()
  local chunk_start = chunk:get_range()
  local content_start = chunk_start + 1
  local relative_row = line_num - content_start
  local col = line:find("%S") or 1

  local ok, parser = pcall(vim.treesitter.get_string_parser, chunk_content, "r")
  if not ok or not parser then
    return nil
  end

  local root = parser:parse()[1]:root()
  local node = root:named_descendant_for_range(relative_row, col - 1, relative_row, col - 1)
  while node do
    local parent = node:parent()
    if parent and (parent:type() == "program" or parent:type() == "braced_expression") then
      break
    end
    node = parent
  end

  if not node then
    return nil
  end

  local start_row, _, end_row, _ = node:range()
  local abs_start = content_start + start_row
  local abs_end = content_start + end_row
  local lines = api.nvim_buf_get_lines(0, abs_start - 1, abs_end, false)
  return lines, abs_end
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

local function style_r_lines(lines)
  local input = table.concat(lines, "\n")
  if input == "" then
    return nil
  end

  local cmd = {
    "Rscript",
    "--vanilla",
    "-e",
    "writeLines(styler::style_text(readLines('stdin', warn = FALSE)))",
  }
  local result = vim.system(cmd, { stdin = input, text = true }):wait()

  if result.code ~= 0 then
    vim.notify((result.stderr or "R formatting failed"):gsub("%s+$", ""), levels.ERROR)
    return nil
  end

  return vim.split((result.stdout or ""):gsub("\n$", ""), "\n", { plain = true })
end

function M.format_buffer()
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  local formatted = style_r_lines(lines)
  if formatted then
    api.nvim_buf_set_lines(0, 0, -1, false, formatted)
    vim.notify("Formatted R buffer", levels.INFO)
  end
end

function M.format_selection()
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local lines = api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local formatted = style_r_lines(lines)
  if formatted then
    api.nvim_buf_set_lines(0, start_line - 1, end_line, false, formatted)
    vim.notify("Formatted R selection", levels.INFO)
  end
end

local anti_slop_ns = api.nvim_create_namespace("r-anti-slop")
local anti_slop_dir = vim.fn.expand("~/.agents/skills/r-anti-slop")
local anti_slop_formatter = anti_slop_dir .. "/scripts/format_r_source.py"
local anti_slop_audit = anti_slop_dir .. "/scripts/audit_r_project.R"
local anti_slop_inflight = {}

local anti_slop_severity = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  advisory = vim.diagnostic.severity.INFO,
}

local function anti_slop_notify(message, level)
  vim.notify(message, level or levels.INFO, { title = "R anti-slop" })
end

local function anti_slop_executable(name)
  return vim.fn.executable(name) == 1 and name or nil
end

local function anti_slop_python()
  return anti_slop_executable("python3") or anti_slop_executable("python")
end

local function anti_slop_current_file()
  local buf = api.nvim_get_current_buf()
  local path = api.nvim_buf_get_name(buf)
  if path == "" then
    return nil, nil, "Save the buffer before running r-anti-slop."
  end
  if vim.fn.fnamemodify(path, ":e"):lower() ~= "r" then
    return nil, nil, "r-anti-slop formats and lints .R files only."
  end
  return path, buf
end

local function anti_slop_write_buffer(buf)
  if vim.bo[buf].buftype ~= "" then
    return false, "Current buffer is not a file."
  end
  if vim.bo[buf].modified then
    local ok, err = pcall(api.nvim_buf_call, buf, function()
      vim.cmd("write")
    end)
    if not ok then
      return false, err
    end
  end
  return true
end

local function anti_slop_audit_root(path)
  local start = vim.fs.dirname(path)
  return vim.fs.root(start, { "DESCRIPTION", "_targets.R", "renv.lock", ".git" }) or start
end

local function anti_slop_apply_formatted_file(buf, path)
  local lines = vim.fn.readfile(path)
  local current = api.nvim_buf_get_lines(buf, 0, -1, false)
  if vim.deep_equal(current, lines) then
    return false
  end
  local view = vim.fn.winsaveview()
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  vim.fn.winrestview(view)
  return true
end

local function anti_slop_findings(report)
  local findings = report and report.findings or {}
  if type(findings) ~= "table" then
    return {}
  end
  if findings.rule_id or findings.file_path then
    return { findings }
  end
  return findings
end

local function anti_slop_publish_diagnostics(buf, path, report)
  local diagnostics = {}
  for _, finding in ipairs(anti_slop_findings(report)) do
    local line = tonumber(finding.line_number) or 1
    local col = tonumber(finding.column_number) or 1
    local rule_id = finding.rule_id or "R-ANTI-SLOP"
    local message = finding.message or "r-anti-slop finding"
    table.insert(diagnostics, {
      lnum = math.max(line - 1, 0),
      col = math.max(col - 1, 0),
      severity = anti_slop_severity[finding.severity] or vim.diagnostic.severity.WARN,
      source = "r-anti-slop",
      code = rule_id,
      message = string.format("[%s] %s", rule_id, message),
    })
  end
  vim.diagnostic.set(anti_slop_ns, buf, diagnostics, { filename = path })
  return #diagnostics
end

local function anti_slop_audit_command(path, report_path, files_json)
  local args = {
    "--fail-on=none",
    "--max-findings=0",
    "--json=" .. report_path,
  }
  if files_json then
    table.insert(args, "--files-json=" .. files_json)
  end

  if anti_slop_executable("uvr") then
    local cmd = { "uvr", "run", anti_slop_audit, "--", path }
    vim.list_extend(cmd, args)
    return cmd
  end

  local cmd = { "Rscript", "--vanilla", anti_slop_audit, path }
  vim.list_extend(cmd, args)
  return cmd
end

local function anti_slop_run_audit(buf, path)
  if vim.fn.filereadable(anti_slop_audit) ~= 1 then
    anti_slop_notify("Missing audit script: " .. anti_slop_audit, levels.ERROR)
    anti_slop_inflight[buf] = nil
    return
  end

  local root = anti_slop_audit_root(path)
  local rel = vim.fs.relpath(root, path)
  local report_dir = vim.fn.tempname() .. "-r-anti-slop"
  vim.fn.mkdir(report_dir, "p")
  local report_path = report_dir .. "/audit.json"
  local files_json
  local audit_path = path

  if rel and rel ~= "" and not rel:match("^%.%.") then
    files_json = report_dir .. "/files.json"
    vim.fn.writefile({ vim.json.encode({ rel }) }, files_json)
    audit_path = root
  end

  anti_slop_notify("Auditing with r-anti-slop…")
  vim.system(
    anti_slop_audit_command(audit_path, report_path, files_json),
    { text = true, timeout = 180000 },
    function(result)
      vim.schedule(function()
        anti_slop_inflight[buf] = nil
        if not api.nvim_buf_is_valid(buf) then
          vim.fn.delete(report_dir, "rf")
          return
        end

        if vim.fn.filereadable(report_path) ~= 1 then
          local detail = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
          anti_slop_notify(
            detail ~= "" and detail or "r-anti-slop audit failed without a report.",
            levels.ERROR
          )
          vim.fn.delete(report_dir, "rf")
          return
        end

        local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(report_path), "\n"))
        vim.fn.delete(report_dir, "rf")
        if not ok then
          anti_slop_notify("Could not parse r-anti-slop report: " .. tostring(decoded), levels.ERROR)
          return
        end
        local count = anti_slop_publish_diagnostics(buf, path, decoded)
        if count == 0 then
          anti_slop_notify("r-anti-slop: no findings")
        else
          anti_slop_notify(string.format("r-anti-slop: %d finding%s", count, count == 1 and "" or "s"))
        end
      end)
    end
  )
end

function M.lint_anti_slop()
  local path, buf, err = anti_slop_current_file()
  if not path then
    anti_slop_notify(err, levels.WARN)
    return
  end
  if anti_slop_inflight[buf] then
    anti_slop_notify("r-anti-slop is already running for this buffer.", levels.WARN)
    return
  end

  local written, write_err = anti_slop_write_buffer(buf)
  if not written then
    anti_slop_notify(write_err, levels.ERROR)
    return
  end

  anti_slop_inflight[buf] = true
  anti_slop_run_audit(buf, path)
end

function M.format_and_lint_anti_slop()
  local path, buf, err = anti_slop_current_file()
  if not path then
    anti_slop_notify(err, levels.WARN)
    return
  end
  if anti_slop_inflight[buf] then
    anti_slop_notify("r-anti-slop is already running for this buffer.", levels.WARN)
    return
  end

  local python = anti_slop_python()
  if not python then
    anti_slop_notify("python3 is required for the r-anti-slop formatter.", levels.ERROR)
    return
  end
  if vim.fn.filereadable(anti_slop_formatter) ~= 1 then
    anti_slop_notify("Missing formatter script: " .. anti_slop_formatter, levels.ERROR)
    return
  end

  local written, write_err = anti_slop_write_buffer(buf)
  if not written then
    anti_slop_notify(write_err, levels.ERROR)
    return
  end

  anti_slop_inflight[buf] = true
  anti_slop_notify("Formatting with r-anti-slop…")
  local width = tonumber(vim.bo[buf].textwidth)
  if not width or width < 20 then
    width = 80
  end

  vim.system(
    { python, anti_slop_formatter, "--write", "--width", tostring(width), path },
    { text = true, timeout = 120000 },
    function(result)
      vim.schedule(function()
        if not api.nvim_buf_is_valid(buf) then
          anti_slop_inflight[buf] = nil
          return
        end

        if result.code == 0 then
          local changed = anti_slop_apply_formatted_file(buf, path)
          anti_slop_notify(changed and "Formatted with r-anti-slop" or "Already formatted by r-anti-slop")
        else
          local detail = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
          anti_slop_notify(
            detail ~= "" and detail or "r-anti-slop formatter failed.",
            levels.ERROR
          )
        end

        anti_slop_run_audit(buf, path)
      end)
    end
  )
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

function M.send_quarto_selection_to_r()
  local lang = require("r.utils").get_lang()
  local canonical = require("r.chunk").resolve_lang(lang)
  if canonical ~= "r" then
    require("r.send").selection(true)
    return
  end

  local lines, end_pos = get_visual_selection_lines()
  if not lines or #lines == 0 then
    return
  end

  local esc = api.nvim_replace_termcodes("<Esc>", true, false, true)
  api.nvim_feedkeys(esc, "nx", false)

  local config = require("r.config").get_config()
  require("r.edit").add_for_deletion(config.source_file)
  vim.fn.writefile(lines, config.source_file)

  local send = require("r.send")
  local source_args = send.get_source_args():gsub("^, ", "")
  local cmd = source_args ~= "" and ("Rnvim.selection(" .. source_args .. ")") or "Rnvim.selection()"
  local ok = send.cmd(cmd)
  if not ok then
    return
  end

  api.nvim_win_set_cursor(0, end_pos)
  require("r.cursor").move_next_line()
end

function M.send_quarto_line_to_r()
  local lang = require("r.utils").get_lang()
  local canonical = require("r.chunk").resolve_lang(lang)
  if canonical ~= "r" then
    require("r.send").line("move")
    return
  end

  local lines, end_line = get_quarto_r_expression()
  if not lines or #lines == 0 then
    require("r.send").line("move")
    return
  end

  local ok = require("r.send").source_lines(lines, nil)
  if not ok then
    return
  end

  local last_line = api.nvim_buf_line_count(0)
  api.nvim_win_set_cursor(0, { math.min(end_line, last_line), 0 })
  require("r.cursor").move_next_line()
end

-- Send the current pipe chain and inspect the result with glimpse()
function M.send_chain_glimpse()
  local glimpse_fn = vim.g.r_chain_glimpse_fn or "dplyr::glimpse"

  local send = require("r.send")
  local has_chain = true
  if type(send.get_pipe_chain) == "function" then
    local ok, chain = pcall(send.get_pipe_chain, 0, false)
    has_chain = not ok or chain ~= nil
  end

  if not has_chain then
    local line_ok, line_result = pcall(send.line)
    if not line_ok then
      vim.notify(string.format("Sending statement failed: %s", line_result), vim.log.levels.WARN)
      return
    elseif line_result == false then
      vim.notify("R is not ready", vim.log.levels.WARN)
      return
    end
  else
    local ok, err = pcall(send.chain)
    if not ok then
      vim.notify(string.format("Sending pipe chain failed: %s", err), vim.log.levels.WARN)
      return
    end
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
