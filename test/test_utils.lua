local M = {}

---
--- Reads a JSON file from the given path and returns the parsed Lua table.
---
---@param filepath string: path to the JSON file
---@return table|nil
M.read_json = function(filepath)
  local ok, content = pcall(vim.fn.readfile, filepath)
  if not ok then
    vim.notify("Failed to read file: " .. filepath, vim.log.levels.ERROR)
    return nil
  end

  local json_string = table.concat(content, "\n")
  local success, decoded = pcall(vim.fn.json_decode, json_string)
  if not success then
    vim.notify("Failed to decode JSON: " .. decoded, vim.log.levels.ERROR)
    return nil
  end

  return decoded
end

--- Compares two strings and prints detailed messages.
---
---@param actual_str string
---@param expected_str string
M.assert_equal_string = function(actual_str, expected_str)
  if actual_str == expected_str then
    print("✅ Matching string")
  else
    print("❌ Mismatching string")
    error("String mismatch:\n  expected: " .. vim.inspect(expected_str) .. "\n  got:      " .. vim.inspect(actual_str))
  end
end

---
--- Compares all metadata and accumulates mismatches instead of failing early.
---
---@param actual_table table
---@param expected_table table
M.assert_equal_table = function(actual_table, expected_table)
  local errors = {}

  for key, expected_val in pairs(expected_table) do
    local actual_val = actual_table[key]
    if actual_val == expected_val or vim.deep_equal(expected_val, actual_val) then
      print("✅ Matching `" .. key .. "` field")
    else
      print("❌ Mismatching `" .. key .. "` field")
      table.insert(errors,
        "Field `" .. key .. "` mismatch:\n  expected: " .. vim.inspect(expected_val) ..
        "\n  got:      " .. vim.inspect(actual_val))
    end
  end

  if #errors > 0 then
    error(table.concat(errors, "\n\n"))
  end
end

return M
