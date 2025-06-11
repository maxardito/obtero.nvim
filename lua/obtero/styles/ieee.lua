local M = {}

local function safe_format(fmt, ...)
  for i = 1, select("#", ...) do
    if select(i, ...) == nil then
      return nil
    end
  end
  return string.format(fmt, ...)
end

M.ieee = function(entry)
  -- Build the author list
  local author_strs = {}
  for _, author in ipairs(entry.authors or {}) do
    table.insert(author_strs, author.first_name:sub(1, 1) .. ". " .. author.last_name)
  end
  local author_line = table.concat(author_strs, ", ")
  author_line = author_line:gsub(", ([^,]+)$", ", and %1") -- Oxford comma fix

  -- Build the editor list (if any)
  local editor_strs = {}
  for _, editor in ipairs(entry.editors or {}) do
    table.insert(editor_strs, editor.first_name:sub(1, 1) .. ". " .. editor.last_name)
  end
  local editor_line = #editor_strs > 0 and (table.concat(editor_strs, ", "):gsub(", ([^,]+)$", ", and %1") .. ", Eds.") or
      nil

  -- Parse publication date
  local pub_year_month = entry.date_published:match("%S+%s+(%S+)") -- grabs the second non-space chunk
  local pub_year, pub_month = pub_year_month:match("(%d+)%-(%d+)")

  local month_names = {
    ["01"] = "Jan.",
    ["02"] = "Feb.",
    ["03"] = "Mar.",
    ["04"] = "Apr.",
    ["05"] = "May",
    ["06"] = "Jun.",
    ["07"] = "Jul.",
    ["08"] = "Aug.",
    ["09"] = "Sep.",
    ["10"] = "Oct.",
    ["11"] = "Nov.",
    ["12"] = "Dec."
  }
  local pub_date = (month_names[pub_month] or "") .. (pub_year and " " .. pub_year or "")

  -- Parse access date
  local access_date_str = nil
  if entry.date_accessed then
    local y, m, d = entry.date_accessed:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y and m and d then
      local access_month = month_names[m] or ""
      access_date_str = string.format("[Accessed: %s %s, %s]", access_month, d, y)
    end
  end

  -- Conditional fields
  local volume = entry.volume and ("vol. " .. entry.volume) or nil
  local issue = entry.issue and ("no. " .. entry.issue) or nil
  local pages = entry.page and ("pp. " .. entry.page) or nil
  local doi = entry.doi and ("doi: " .. entry.doi) or nil
  local url = entry.url and ("[Online]. Available: " .. "[" .. entry.url .. "](" .. entry.url .. ")") or nil
  local publication = (entry.publication and "*" .. entry.publication .. "*") or nil

  -- Join parts with commas and filter out nils
  local parts = {
    string.format('%s, "%s,"', author_line, entry.title),
    publication,
    editor_line,
    volume,
    issue,
    pages,
    pub_date,
    doi,
    string.format('%s. %s', url, access_date_str)
  }

  -- Remove nil or empty string parts
  local filtered_parts = {}
  for _, part in pairs(parts) do
    if part and part ~= "" then
      table.insert(filtered_parts, part)
    end
  end

  local citation = table.concat(filtered_parts, ", ") .. "."
  return citation
end

return M
