--[[
  Obtero.nvim - IEEE
  -----------------------------------

  Provides functionality to format bibliographic entries into IEEE citation style.
]]

local M = {}

---
--- Parses the publication and access dates from an entry and returns formatted strings.
---
---@param entry table: A bibliographic entry containing optional `date_published` and `access_date` fields.
---@return string, string: A formatted publication date (e.g., "Jan. 2024") and a formatted access date (e.g., "Accessed Jan. 3, 2024"), or an empty string if missing.
local function parse_entry_dates(entry)
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

  -- Parse publication date
  local pub_date
  if entry.date_published and entry.date_published ~= "" then
    local year, month, day = entry.date_published:match("(%d+)%-(%d+)%-(%d+)")
    if year and month then
      if day == nil or tonumber(day) == 0 then
        pub_date = string.format("%s %s", month_names[month] or "", year)
      else
        pub_date = string.format("%s %d, %s", month_names[month] or "", tonumber(day), year)
      end
    end
  else
    pub_date = ""
  end

  -- Parse access date
  local access_date
  if entry.date_accessed and entry.date_accessed ~= "" then
    local year, month, day = entry.date_accessed:match("(%d+)%-(%d+)%-(%d+)")
    if year and month and day then
      day = tonumber(day)
      if day == 0 then
        access_date = string.format("Accessed %s %s", month_names[month] or "", year) .. "."
      else
        access_date = string.format("Accessed %s %d, %s", month_names[month] or "", day, year) .. "."
      end
    end
  else
    access_date = ""
  end

  return pub_date, access_date
end

---
--- Formats a bibliographic entry into an IEEE-style citation string.
---
---@param entry table: A bibliographic entry containing fields such as `authors`, `title`, `publication`, `volume`, `issue`, `page`, `doi`, `url`, `date_published`, and `access_date`.
---@return string: A formatted citation string following IEEE style.
M.ieee = function(entry)
  -- Build the author list
  local author_strs = {}
  for _, author in ipairs(entry.authors or {}) do
    table.insert(author_strs, author.first_name:sub(1, 1) .. ". " .. author.last_name)
  end
  local author_line = table.concat(author_strs, ", ")
  author_line = author_line:gsub(", ([^,]+)$", ", and %1") -- Oxford comma fix

  -- Conditional fields
  local book_title = entry.title and ("*" .. entry.title .. "*, ")
  local journal_title = entry.title and ("\"" .. entry.title .. ",\" ")
  local volume = entry.volume and ("vol. " .. entry.volume .. ", ") or nil
  local issue = entry.issue and ("no. " .. entry.issue .. ", ") or nil
  local pages = entry.page and ("pp. " .. entry.page .. ", ") or nil
  local doi = entry.doi and ("doi: " .. entry.doi .. ". ") or nil
  local url = entry.url and ("[Online]. Available: " .. "[" .. entry.url .. "](" .. entry.url .. "). ") or nil
  local publication = (entry.publication and "*" .. entry.publication .. "*, ") or nil
  local publisher = entry.publisher and (entry.publisher .. ", ") or nil
  local location = entry.location and (entry.location .. ": ") or nil
  local edition = entry.edition and (entry.edition .. ". ") or nil

  local pub_date, access_date = parse_entry_dates(entry)

  -- Full citation
  local citation
  if entry.type == "Journal Article" then
    citation = author_line ..
        ", " ..
        journal_title ..
        publication .. volume .. issue .. pages .. pub_date .. doi .. url .. access_date
  elseif entry.type == "Book" then
    citation = author_line .. ", " .. book_title .. edition .. location .. publisher .. pub_date .. "."
  end

  return citation
end

return M
