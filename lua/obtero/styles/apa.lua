local M = {}

-- Helper to extract initials from first names
local function get_initials(first_name)
  local initials = {}
  for word in first_name:gmatch("[%w'-]+") do
    table.insert(initials, word:sub(1, 1):upper() .. ".")
  end
  return table.concat(initials, " ")
end

-- Format names APA-style
local function format_name_list(list)
  local name_strs = {}
  for _, person in ipairs(list or {}) do
    local initials = get_initials(person.first_name)
    table.insert(name_strs, person.last_name .. ", " .. initials)
  end
  if #name_strs > 1 then
    name_strs[#name_strs] = "& " .. name_strs[#name_strs]
  end
  return table.concat(name_strs, ", ")
end

-- Convert title to sentence case
local function to_sentence_case(title)
  if not title or title == "" then return "" end
  -- lowercase entire string
  local lower_title = title:lower()
  -- uppercase first letter
  return lower_title:sub(1, 1):upper() .. lower_title:sub(2)
end


M.apa = function(entry)
  local authors = format_name_list(entry.authors or {})
  local editors = format_name_list(entry.editors or {})

  local year = entry.date_published and entry.date_published:match("^(%d%d%d%d)") or "n.d."
  local date_str = "(" .. year .. ")."

  local title = to_sentence_case(entry.title or "")
  local title_str = title .. "."

  local editor_str = #editors > 0 and ("In " .. editors .. " (Ed.),") or nil

  local volume = entry.volume and ("*" .. entry.volume .. "*") or ""
  local issue = entry.issue and ("(" .. entry.issue .. ")") or ""
  local pages = entry.page and (", " .. entry.page) or ""

  local doi = entry.doi and ("https://doi.org/" .. entry.doi) or nil

  local journal_str = (entry.publication and ("*" .. entry.publication .. "*" .. ", " .. volume .. issue .. pages .. ".")) or
      ""

  -- Optional access date
  local access_str = ""
  if entry.date_accessed then
    local y, m, d = entry.date_accessed:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y and m and d then
      local months = {
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
      local month = months[m] or ""
      access_str = string.format("Accessed %s %s, %s.", month, d, y)
    end
  end

  -- Combine URL + access
  local online_info = nil
  if doi then
    online_info = doi
  else
    online_info = entry.url and ("Retrieved from " .. ("[" .. entry.url .. "](" .. entry.url .. ")." .. access_str)) or
        ""
  end

  local parts = {
    authors,
    date_str,
    title_str,
    editor_str,
    journal_str,
    online_info,
  }

  local result = {}
  for _, part in pairs(parts) do
    if part and part ~= "" then
      table.insert(result, part)
    end
  end

  return table.concat(result, " ")
end

return M
