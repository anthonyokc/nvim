local M = {}

-- R heading fold function for foldexpr
function M.R_heading_fold(lnum)
  local s = vim.fn.getline(lnum)
  
  -- Header lines
  if s:match("^%s*###%s") then return 3 end -- H3
  if s:match("^%s*##%s") then return 2 end  -- H2
  if s:match("^%s*#%s") then return 1 end   -- H1
  
  -- Non-header: inherit nearest previous header, but one level deeper so
  -- folds start *after* the header and end at the next header of same/higher level
  for i = lnum - 1, 1, -1 do
    local p = vim.fn.getline(i)
    if p:match("^%s*###%s") then return 4 end -- content under H3
    if p:match("^%s*##%s") then return 3 end  -- content under H2
    if p:match("^%s*#%s") then return 2 end   -- content under H1
  end
  return 0                                      -- before first header
end

-- Setup R heading folds for R files
function M.setup()
  local grp = vim.api.nvim_create_augroup("RHeadingFolds", { clear = true })
  
  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
    group = grp,
    callback = function(ev)
      if vim.bo[ev.buf].filetype ~= "r" then return end
      local win = ev.win or vim.api.nvim_get_current_win()
      vim.api.nvim_set_option_value("foldenable", true, { win = win })
      vim.api.nvim_set_option_value("foldmethod", "expr", { win = win })
      vim.api.nvim_set_option_value("foldexpr", "v:lua.R_heading_fold(v:lnum)", { win = win })
      vim.api.nvim_set_option_value("foldlevelstart", 99, { win = win })
      vim.api.nvim_set_option_value("foldignore", "", { win = win })
    end,
  })
  
  -- Make the fold function globally available
  _G.R_heading_fold = M.R_heading_fold
end

return M