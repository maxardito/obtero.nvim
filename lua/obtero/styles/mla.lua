local M = {}

M.mla = function(entry)
  local authors = entry.authors or {}

  local function format_author(author)
    return author.last_name .. ", " .. author.first_name
  end

  local author_line
  if #authors == 0 then
    author_line = ""
  elseif #authors == 1 then
    author_line = format_author(authors[1])
  elseif #authors == 2 then
    -- MLA: Last, First, and First Last
    author_line = format_author(authors[1]) .. ", and " .. authors[2].first_name .. " " .. authors[2].last_name
  else
    local author_strs = {}
    for i = 1, #authors - 1 do
      table.insert(author_strs, format_author(authors[i]))
    end
    author_line = table.concat(author_strs, ", ") .. ", and " .. format_author(authors[#authors])
  end

  local editors = entry.editors or {}

  local editor_line = ""
  if #editors == 1 then
    editor_line = "Edited by " .. editors[1].first_name .. " " .. editors[1].last_name
  elseif #editors == 2 then
    editor_line = "Edited by " ..
        editors[1].first_name ..
        " " .. editors[1].last_name .. " and " .. editors[2].first_name .. " " .. editors[2].last_name
  elseif #editors > 2 then
    local editor_strs = {}
    for i = 1, #editors - 1 do
      table.insert(editor_strs, editors[i].first_name .. " " .. editors[i].last_name)
    end
    editor_line = "Edited by " ..
        table.concat(editor_strs, ", ") .. ", and " .. editors[#editors].first_name .. " " .. editors[#editors]
        .last_name
  end


  -- Parse publication date
  local pub_year, pub_month, pub_day = entry.date_published and entry.date_published:match("(%d%d%d%d)%-(%d%d)%-(%d%d)") or
      {}
  local month_names = {
    ["01"] = "Jan.",
    ["02"] = "Feb.",
    ["03"] = "Mar.",
    ["04"] = "Apr.",
    ["05"] = "May",
    ["06"] = "June",
    ["07"] = "July",
    ["08"] = "Aug.",
    ["09"] = "Sept.",
    ["10"] = "Oct.",
    ["11"] = "Nov.",
    ["12"] = "Dec."
  }
  local pub_date = (month_names[pub_month] or "") ..
      (pub_day and " " .. tonumber(pub_day) or "") .. (pub_year and " " .. pub_year or "")
  pub_date = pub_date:gsub("^%s+", ""):gsub("%s+$", "") -- trim

  -- Access date
  local access_str = nil
  if entry.date_accessed then
    local y, m, d = entry.date_accessed:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y and m and d then
      local access_month = month_names[m] or ""
      access_str = string.format("Accessed %d %s %s", tonumber(d), access_month, y)
    end
  end

  -- Conditional fields
  local title = entry.title and string.format('"%s."', entry.title) or nil
  local publication = entry.publication and string.format("*%s*", entry.publication) or nil
  local volume = entry.volume and ("vol. " .. entry.volume) or nil
  local issue = entry.issue and ("no. " .. entry.issue) or nil
  local pages = entry.page and ("pp. " .. entry.page) or nil
  local url = entry.url and ("[" .. entry.url .. "](" .. entry.url .. ")") or nil

  -- Combine all parts
  local parts = {
    author_line,
    title,
    publication,
    volume,
    issue,
    pages,
    pub_date ~= "" and pub_date or nil,
    editor_line,
    url,
    access_str
  }

  -- Remove nil or empty values
  local filtered_parts = {}
  for _, part in pairs(parts) do
    if part and part ~= "" then
      table.insert(filtered_parts, part)
    end
  end

  local citation = table.concat(filtered_parts, ". ") .. "."
  return citation
end

return M
