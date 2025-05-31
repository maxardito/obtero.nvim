-- db.lua

-- TODO: Make the headers reference the types
-- A simple SQLite query wrapper using io.popen
-- Encapsulated as a Lua class with configurable database path
local DB = {}

DB.__index = DB

-- Constructor
-- @param db_path string: Path to the SQLite database
function DB.new(db_path)
  local self = setmetatable({}, DB)
  self.db_path = db_path
  return self
end

-- Executes a SQL query against the configured database
-- @param query string: The SQL query to execute
-- @return table: A table of rows, each row is a table of fields
function DB:query(query)
  -- Escape double quotes in the query
  query = query:gsub('"', '\\"')

  local cmd = [[sqlite3 -separator "|" "]] .. self.db_path .. [[" "]] .. query .. [["]]
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

  return rows
end

return DB
