-- Obsidian dependencies
local util = require "obsidian.util"
local log = require "obsidian.log"
local obsidian = require("obsidian")

-- Obtero dependencies
local utils = require "obtero.utils"
local ui = require "obtero.ui"

-- TODO: Refactor to keys.lua and make more search types
-- Factory to create a completion function with access to the dynamic zotero path
local function make_jsonkey_completion(zotero_path)
  return function(arg_lead)
    local json = vim.fn.readfile(zotero_path)
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
end

-- Main entry point
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
    -- Create and register a temporary global completion function
    local completion_func = make_jsonkey_completion(config.zotero.path)
    local completion_name = "__obtero_jsonkey_completion"
    _G[completion_name] = completion_func

    -- Prompt user with autocomplete
    key = util.input("Enter citation key (Press <Tab> for autocomplete): ", {
      completion = "customlist,v:lua." .. completion_name,
    })

    -- Clean up the temporary global
    _G[completion_name] = nil

    if (not key) or (key == "") then
      log.warn "Aborted"
      return
    end
  end

  -- Load Zotero JSON and find the entry
  local file = io.open(config.zotero.path, "r")
  if not file then
    error("Could not open file: " .. config.zotero.path)
  end

  local zotero_json = file:read("*a")
  file:close()

  local zotero_tbl = utils.json_to_table(zotero_json)
  local entry = utils.find_by_id(zotero_tbl, key)
  ui.show_explorer_popup(entry)
end
