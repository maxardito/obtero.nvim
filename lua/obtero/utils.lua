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

--
-- Helper to split "Last, First" into { first_name = ..., last_name = ... }
--
---@param name string
---@return Contributor
M.parse_contributor = function(name)
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

return M
