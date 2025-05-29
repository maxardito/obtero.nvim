local obsidian = require("obsidian")

return function(config, data)
  local zotero_path = "/home/maxwell/zotero/zotero.sqlite" -- update this!

  local cmd = [[sqlite3 "]] .. zotero_path .. [[" "
    SELECT * FROM items WHERE itemID = 70;
  "]]

  local handle = io.popen(cmd)
  if not handle then return end

  local result = handle:read("*a")
  handle:close()

  print(vim.inspect(result))
end
