--[[
  Obtero.nvim - Database
  -----------------------------------

  A lightweight SQLite query wrapper implemented using `io.popen` to
  execute SQL queries on Zotero and Better BibTeX SQLite databases.

  Features:
    - Stores paths for Zotero and Better BibTeX SQLite databases
    - Provides a simple `query` method to run arbitrary SQL queries
      against the Zotero and BBT database
    - Returns query results as a table of rows, with each row
      represented as a table of field strings
    - Handles escaping of double quotes in SQL queries

  Note:
    This wrapper relies on the external `sqlite3` CLI tool being
    available in the system PATH.
]]

---@class DB
---@field zotero_db_path string
---@field bibtex_db_path string
---@field db_path string Path to the SQLite database
---@field query fun(self: DB, query: string): table
local DB = {}
DB.__index = DB

---
--- Constructor for the DB class
---
---@param zotero_db_path string Path to the Zotero SQLite database
---@param bibtex_db_path string Path to the Better Bibtex SQLite database
---@return DB
function DB.new(zotero_db_path, bibtex_db_path)
  local self = setmetatable({}, DB)
  self.zotero_db_path = zotero_db_path
  self.bibtex_db_path = bibtex_db_path
  return self
end

---
--- Executes a SQL query against the configured database
---
---@param query string SQL query string to execute
---@return string[][] Table of rows, each row is a table of fields
function DB:query(query)
  -- Escape double quotes in the query
  query = query:gsub('"', '\\"')

  local cmd = [[sqlite3 -separator "|" "]] .. self.zotero_db_path .. [[" "]] .. query .. [["]]
  local handle = io.popen(cmd)

  if not handle then
    error("Invalid handle: Check that the Zotero path is correct in your config file")
  end

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
