-- Obsidian dependencies
local util = require "obsidian.util"
local log = require "obsidian.log"
local obsidian = require("obsidian")

-- Obtero dependencies
local utils = require "obtero.utils"
local ui = require "obtero.ui"

function _G.jsonkey_completion(arg_lead)
  ---FIX:  Refactor the path here
  local json = vim.fn.readfile("/home/maxwell/zotero/zotero.json")
  local decoded = vim.fn.json_decode(table.concat(json, "\n"))

  local matches = {}
  for _, entry in ipairs(decoded) do
    local id = entry.id or ""
    if id:lower():find(arg_lead:lower(), 1, true) == 1 then
      table.insert(matches, id)
    end
  end
  return matches
end

return function(config, data)
  local client = obsidian.get_client()
  local key
  local picker = client:picker()

  if not picker then
    log.err "No picker configured"
    return
  end

  if data.args:len() > 1 then
    log.warn "Error: Takes one argument citation key"
    return
  elseif data.args:len() == 1 then
    key = data.args
  else
    key = util.input("Enter citation key (Press <Tab> for autocomplete): ",
      { completion = "customlist,v:lua.jsonkey_completion" }
    )
    if (not key) or (key == "") then
      log.warn "Aborted"
      return
    end

    local file = io.open(config.zotero.path, "r")

    if not file then
      error("Could not open file: " .. config.zotero.path)
    end

    local zotero_json = file:read("*a")

    file:close()

    local zotero_tbl = utils.json_to_table(zotero_json)
    local entry = utils.find_by_id(zotero_tbl, key)
    ui.show_table_popup(entry)
  end
end
