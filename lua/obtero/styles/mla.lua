--[[
  Obtero.nvim - MLA
  -----------------------------------

  Provides functionality to format bibliographic entries into MLA citation style.
]]
local M = {}

---
--- Formats a bibliographic entry into an MLA-style citation string.
---
---@param entry table: A bibliographic entry containing fields such as `authors`, `title`, `publication`, `volume`, `issue`, `page`, `doi`, `url`, `date_published`, and `access_date`.
---@return string: A formatted citation string following MLA style.
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

  author_line = author_line .. ". "

  -- Parse publication date
  local pub_year, pub_month, pub_day = nil, nil, nil
  if entry.date_published then
    pub_year, pub_month, pub_day = entry.date_published:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
  end

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

  -- Pub date
  local pub_date = ""

  if pub_month and month_names[pub_month] then
    pub_date = pub_date .. month_names[pub_month]
  end

  if pub_day and pub_day ~= "00" then
    pub_date = pub_date .. " " .. tonumber(pub_day)
  end

  if pub_year then
    pub_date = pub_date .. " " .. pub_year
  end

  pub_date = pub_date:gsub("^%s+", ""):gsub("%s+$", "") -- trim

  -- Access date
  local access_str = nil
  if entry.date_accessed then
    local y, m, d = entry.date_accessed:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y and m and d then
      local access_month = month_names[m] or ""
      if d == "0" then
        access_str = string.format("Accessed %s %s", access_month, y)
      else
        access_str = string.format("Accessed %d %s %s", tonumber(d), access_month, y)
      end
    end
  end

  -- Conditional fields
  local journal_title = (entry.title and ("\"" .. entry.title .. "." .. "\" ")) or nil
  local book_title = (entry.title and ("*" .. entry.title .. "*. ")) or nil
  local publication = (entry.publication and ("*" .. entry.publication .. "*, ")) or nil
  local publisher = (entry.publisher and (entry.publisher .. ", ")) or nil
  local volume = entry.volume and ("vol. " .. entry.volume .. ", ") or nil
  local issue = entry.issue and ("no. " .. entry.issue .. ", ") or nil
  local pages = entry.page and ("pp. " .. entry.page .. ". ") or nil

  -- Pub year for journal / book
  local journal_pub_year = pub_year and (pub_year .. ", ") or nil
  local book_pub_year = pub_year and (pub_year .. ".") or nil

  -- DOI and URL
  local doi = entry.doi and ("https://doi.org/" .. entry.doi) or nil
  local url = (not doi and entry.url) and ("[" .. entry.url .. "](" .. entry.url .. ")") or nil

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
    citation = author_line .. journal_title .. publication .. volume .. issue .. journal_pub_year .. pages .. online_info
  elseif entry.type == "Book" then
    citation = author_line .. book_title .. publisher .. book_pub_year
  end

  return citation
end

return M
