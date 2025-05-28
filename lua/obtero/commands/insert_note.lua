local obsidian = require("obsidian")

return function(config, data)
  local zotero_path = "/home/maxwell/zotero/zotero.sqlite" -- update this!

  local cmd = [[sqlite3 "]] .. zotero_path .. [[" "
    SELECT * FROM itemNotes WHERE itemID = 70;
  "]]

  local handle = io.popen(cmd)
  if not handle then return end

  local result = handle:read("*a")
  handle:close()

  local tags = {}
  for line in result:gmatch("[^\r\n]+") do
    local id, title, tag = line:match("([^|]+)|([^|]*)|([^|]*)")
    table.insert(tags, { id = id, title = title, tag = tag })
  end

  print(vim.inspect(tags))
end
