local M = {}

local function deent(s)
  return (s or "")
    :gsub('&nbsp;', ' ')
    :gsub('&lt;', '<')
    :gsub('&gt;', '>')
    :gsub('&amp;', '&')
end

local function strip_tags(s)
  -- strip HTML comments and tags
  s = (s or "")
  s = s:gsub('<!%-%-.-%-%->', '')
  s = s:gsub('</?[^>]+>', '')
  return s
end

local function clean_line(s)
  return deent(strip_tags(s))
end

---Sanitize HTML-like content in-place (for tables) or by value (for strings)
---@param contents string|string[]
---@return string|string[]
function M.sanitize_html(contents)
  if type(contents) == 'string' then
    return clean_line(contents)
  elseif type(contents) == 'table' then
    for i, s in ipairs(contents) do
      contents[i] = clean_line(s)
    end
    return contents
  end
  return contents
end

return M
