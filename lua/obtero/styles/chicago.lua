--[[
  Obsidian.nvim - Chicago
  -----------------------------------

  Provides functionality to format bibliographic entries into Chicago citation style.
]]

local M = {}

---
--- Formats a bibliographic entry into an Chicago-style citation string.
---
---@param entry table: A bibliographic entry containing fields such as `authors`, `editors`, `title`, `publication`, `volume`, `issue`, `page`, `doi`, `url`, `date_published`, and `access_date`.
---@return string: A formatted citation string following Chicago style.
M.chicago = function(entry)
  local month_names = {
    ["01"] = "January",
    ["02"] = "February",
    ["03"] = "March",
    ["04"] = "April",
    ["05"] = "May",
    ["06"] = "June",
    ["07"] = "July",
    ["08"] = "August",
    ["09"] = "September",
    ["10"] = "October",
    ["11"] = "November",
    ["12"] = "December"
  }

  local contributors = {}
  local role = "authors"
  if entry.authors and #entry.authors > 0 then
    for i, author in ipairs(entry.authors) do
      if i == 1 then
        table.insert(contributors, author.last_name .. ", " .. author.first_name) -- Inverted
      else
        table.insert(contributors, author.first_name .. " " .. author.last_name)  -- Not inverted
      end
    end
  elseif entry.editors and #entry.editors > 0 then
    role = "editors"
    for i, editor in ipairs(entry.editors) do
      if i == 1 then
        table.insert(contributors, editor.last_name .. ", " .. editor.first_name)
      else
        table.insert(contributors, editor.first_name .. " " .. editor.last_name)
      end
    end
  end

  local contributor_line = table.concat(contributors, ", ")
  contributor_line = contributor_line:gsub(", ([^,]+)$", ", and %1") -- Oxford comma

  if role == "editors" then
    contributor_line = contributor_line .. (#contributors > 1 and ", eds." or ", ed.")
  end

  -- Year
  local pub_year = (entry.date_published and "(" .. entry.date_published:match("(%d%d%d%d)") .. ")") or "n.d."

  -- Title and publication
  local title = (entry.title and ('"' .. entry.title .. "." .. '"')) or ""
  local publication = (entry.publication and ("*" .. entry.publication .. "*")) or ""

  -- Volume/issue/pages
  local volume = (entry.volume and (entry.volume .. ", ")) or nil
  local issue = entry.issue and ("no. " .. entry.issue .. " ") or nil
  local pages = entry.page and (": " .. entry.page .. ".") or ""

  local vol_issue_pages = nil
  if volume then
    vol_issue_pages = volume .. (issue or "") .. pub_year .. pages
  elseif pages ~= "" then
    vol_issue_pages = pages:sub(3) -- strip ": "
  end

  -- DOI and URL
  local doi = entry.doi and ("https://doi.org/" .. entry.doi) or nil
  local url = (not doi and entry.url) and ("[" .. entry.url .. "](" .. entry.url .. ")") or nil

  -- Access date
  local access_str = nil
  if entry.date_accessed then
    local y, m, d = entry.date_accessed:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y and m and d then
      local month = month_names[m] or ""
      access_str = string.format("Retrieved %s %d, %s", month, tonumber(d), y)
    end
  end

  -- Combine URL + access
  local online_info = nil
  if url then
    online_info = access_str and (access_str .. ", from " .. url) or ("Available at: " .. url)
  elseif doi then
    online_info = doi
  end

  -- Final citation
  local parts = {
    contributor_line,
    title,
    publication,
    vol_issue_pages,
    online_info
  }

  local filtered_parts = {}
  for _, part in pairs(parts) do
    if part and part ~= "" then
      table.insert(filtered_parts, part)
    end
  end

  return table.concat(filtered_parts, " ") .. "."
end

return M
