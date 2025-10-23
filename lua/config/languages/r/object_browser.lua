local M = {}

local api = vim.api
local map = vim.keymap

-- Object browser state
local ob = { win = nil, buf = nil }
local OB_PAT = vim.g.rnvim_objbr_name_pat or "Object_Browser"

-- Check if buffer is object browser
local function is_objbr_buf(b)
  if not (b and api.nvim_buf_is_valid(b)) then return false end
  local name = api.nvim_buf_get_name(b)
  return type(name) == "string" and name:find(OB_PAT) ~= nil
end

-- Find object browser window
local function find_objbr_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    local b = api.nvim_win_get_buf(w)
    if is_objbr_buf(b) then return w, b end
  end
end

-- Find object browser buffer
local function find_objbr_buf()
  for _, b in ipairs(api.nvim_list_bufs()) do
    if is_objbr_buf(b) then return b end
  end
end

-- Start object browser
local function start_objbr()
  api.nvim_feedkeys(api.nvim_replace_termcodes("<Plug>ROBToggle", true, true, true), "n", false)
end

-- Float object browser
local function float_objbr()
  local win, buf = find_objbr_win()
  buf = buf or find_objbr_buf()
  if not (buf and api.nvim_buf_is_valid(buf)) then
    return false
  end

  -- Open FLOAT first (keeps buf alive even if the split closes)
  local W = math.floor(vim.o.columns * 0.4)
  local H = math.floor(vim.o.lines * 0.80)
  local float = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = W,
    height = H,
    row = math.floor((vim.o.lines - H) / 2),
    col = vim.o.columns - W - 2,
    border = "rounded",
    style = "minimal",
    noautocmd = true,
  })

  -- Close the original OB split if it exists and isn't our float
  if win and api.nvim_win_is_valid(win) and win ~= float then
    pcall(api.nvim_win_close, win, true)
  end

  ob.win, ob.buf = float, buf
  return true
end

-- Ensure object browser exists then float it
local function ensure_objbr_then_float()
  -- If neither buffer nor window exists, start one
  local w0, b0 = find_objbr_win()
  if not (b0 or w0) then start_objbr() end

  -- Retry a few times while R.nvim creates the buffer/window
  local tries, interval = 30, 50 -- ~1.5s max
  local function step()
    if float_objbr() then return end
    tries = tries - 1
    if tries <= 0 then
      vim.notify("Object_Browser not found after starting.", vim.log.levels.WARN)
      return
    end
    vim.defer_fn(step, interval)
  end
  vim.defer_fn(step, 60)
end

-- Toggle object browser floating window
function M.toggle()
  if ob.win and api.nvim_win_is_valid(ob.win) then
    api.nvim_win_close(ob.win, true)
    ob.win, ob.buf = nil, nil
    return
  end
  ensure_objbr_then_float() -- start if missing, then float
end

-- Setup object browser keymap
function M.setup()
  map.set("n", "<leader>ro", M.toggle, { desc = "R.nvim Object Browser (FLOAT toggle)" })
end

return M
