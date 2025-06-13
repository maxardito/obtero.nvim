local M = {}

---
--- Find an entry by its ID in a list of tables.
---
---@param entries table[] A list of tables, each with an "id" field.
---@param target_id string? The ID to search for.
---@return table|nil The matching entry if found, or nil otherwise.
M.find_by_id = function(entries, target_id)
  for _, entry in ipairs(entries) do
    if entry.id == target_id then
      return entry
    end
  end
  return nil
end

---Formats a list of contributors into a single string: "First Last, First Last, ... and First Last"
---@param contributors Contributor[]
---@return string
M.contributors_to_string = function(contributors)
  local names = {}
  for _, c in ipairs(contributors) do
    if c.first_name ~= "" then
      table.insert(names, c.first_name .. " " .. c.last_name)
    else
      -- fallback for single-name contributors like "CCRU"
      table.insert(names, c.last_name)
    end
  end

  local count = #names
  if count == 0 then
    return ""
  elseif count == 1 then
    return names[1]
  elseif count == 2 then
    return names[1] .. " and " .. names[2]
  else
    return table.concat(names, ", ", 1, count - 1) .. ", and " .. names[count]
  end
end

--
-- Helper to split "Last, First" into { first_name = ..., last_name = ... }
--
---@param name string
---@return Contributor
M.string_to_contributors = function(name)
  local last, first = name:match("^(.-),%s*(.+)$")
  if first and last then
    return {
      first_name = first,
      last_name = last
    }
  else
    -- fallback if name has no comma (e.g., "CCRU")
    return {
      first_name = "",
      last_name = name
    }
  end
end

---
---Convert a JSON string to a Lua table.
---
---@param json_str string
---@return table
M.json_to_table = function(json_str)
  local ok, tbl = pcall(vim.fn.json_decode, json_str)
  if not ok then
    error("Invalid JSON string")
  end

  return tbl
end

--
-- Copy a table to another table
--
---@param source table
---@param target table
M.copy_table = function(source, target)
  for k, v in pairs(source) do
    target[k] = v
  end
end

--
-- Copy an array-like table (indexed numerically)
--
---@param source table
---@return Array
M.copy_array = function(source)
  local result = {}
  for i, v in ipairs(source) do
    result[i] = v
  end
  return result
end

---
--- Flatten a table, helpful for colums-to-rows conversion from SQLite
---
---@param input_table table
---@return table
M.flatten_table = function(input_table)
  local result = {}
  for i, pair in ipairs(input_table) do
    result[i] = pair[1]
  end
  return result
end

--- Converts entries in a teble to a space-separated string with commas.
--- @param entry table: A table containing multiple entries.
--- @return string: A space-separated string with each entry separated by ', '.
M.list_to_string = function(entry)
  return table.concat(entry, ", ")
end

--- Converts a list of tags in an entry to a space-separated string with octothorpes.
--- @param entry table: A table containing a `tags` field, which is a list of tag strings.
--- @return string: A space-separated string with each tag prefixed by '#'.
M.tags_to_string = function(entry)
  local tags = {}
  for _, tag in ipairs(entry) do
    table.insert(tags, "#" .. tag)
  end
  return table.concat(tags, " ")
end


-- Function to insert text at the current cursor position
---@param text string
M.insert_text = function(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- get current cursor position (1-indexed)
  local current_line = vim.api.nvim_get_current_line()

  -- Insert text at cursor column (Lua strings are 1-indexed)
  local new_line = current_line:sub(1, col) .. text .. current_line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)

  -- Move cursor to after inserted text (optional)
  vim.api.nvim_win_set_cursor(0, { row, col + #text })
end

return M
