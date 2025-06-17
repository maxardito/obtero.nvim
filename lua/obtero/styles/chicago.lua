--[[
  Obtero.nvim - Chicago
  -----------------------------------

  Provides functionality to format bibliographic entries into Chicago citation style.
]]

local M = {}

---
--- Formats a bibliographic entry into an Chicago-style citation string.
---
---@param entry table: A bibliographic entry containing fields such as `authors`, `title`, `publication`, `volume`, `issue`, `page`, `doi`, `url`, `date_published`, and `access_date`.
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
  end

  local contributor_line = table.concat(contributors, ", ")
  contributor_line = contributor_line:gsub(", ([^,]+)$", ", and %1") .. ". " -- Oxford comma

  -- Year
  local pub_year = (entry.date_published and (entry.date_published:match("(%d%d%d%d)") .. ". ")) or "n.d. "

  -- Title and publication
  local journal_title = (entry.title and ("\"" .. entry.title .. "." .. "\" ")) or ""
  local book_title = (entry.title and ("*" .. entry.title .. "*. ")) or ""
  local publication = (entry.publication and ("*" .. entry.publication .. "* ")) or ""

  -- Volume/issue/pages
  local volume = (entry.volume and (entry.volume .. ", ")) or nil
  local issue = entry.issue and ("no. " .. entry.issue .. " ") or nil
  local pages = entry.page and (": " .. entry.page .. ".") or ""


  -- Publisher
  local publisher = (entry.publisher and (entry.publisher .. ".")) or ""
  local location = (entry.location and (entry.location .. ": ")) or nil

  local vol_issue_pages = nil
  if volume then
    vol_issue_pages = volume .. (issue or "") .. pages .. " "
  elseif pages ~= "" then
    vol_issue_pages = pages:sub(3) .. " " -- strip ": "
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
      local day = tonumber(d)
      if day == 0 then
        -- If day is 0, omit the day
        access_str = string.format("Retrieved %s, %s", month, y)
      else
        -- Otherwise, print full date with day
        access_str = string.format("Retrieved %s %d, %s", month, day, y)
      end
    end
  end

  -- Combine URL + access
  local online_info = nil
  if url then
    online_info = access_str and (access_str .. ", from " .. url .. ".") or ("Available at: " .. url .. ".")
  elseif doi then
    online_info = doi .. "."
  end

  -- Full citation
  local citation
  if entry.type == "Journal Article" then
    citation = contributor_line .. pub_year .. journal_title .. publication .. vol_issue_pages .. online_info
  elseif entry.type == "Book" then
    citation = contributor_line .. pub_year .. book_title .. location .. publisher
  end

  return citation
end

return M
