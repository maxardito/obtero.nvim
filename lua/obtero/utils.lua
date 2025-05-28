-- TODO: Docs should look something like this file? Doc autogeneration?
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

return M
