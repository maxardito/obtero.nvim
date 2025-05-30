local M = {}

M.query = function(query, db_path)
  -- Escape double quotes in the query
  query = query:gsub('"', '\\"')

  local cmd = [[sqlite3 -separator "|" "]] .. db_path .. [[" "]] .. query .. [["]]
  local handle = io.popen(cmd)
  if not handle then return end

  local result = handle:read("*a")
  handle:close()

  local rows = {}
  for line in result:gmatch("[^\r\n]+") do
    local fields = {}
    for field in line:gmatch("([^|]*)") do
      table.insert(fields, field)
    end
    table.insert(rows, fields)
  end

  print(vim.inspect(rows))
end

return M
