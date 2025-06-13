-- Obsidian dependencies
local util = require "obsidian.util"
local log = require "obsidian.log"
local obsidian = require("obsidian")
local Explorer = require("obtero.explorer")

-- Obtero dependencies
local ui = require "obtero.ui"
local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"

-- Main entry point
return function(config, data)
  local client = obsidian.get_client()
  local key
  local picker = client:picker()

  local reference = Entries.new(
    DB.new(
      config.zotero.path .. "/zotero.sqlite",
      config.zotero.path .. "/better-bibtex.sqlite"
    )
  )

  if not picker then
    log.err "No picker configured"
    return
  end

  -- Create and register a temporary global completion function
  -- TODO: More complete functions
  local completion_func = function() return reference:get_citation_keys() end
  local completion_name = "__obtero_completion_by_citation_keys"
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

  local fields = reference:get_fields(key)
  local tags = reference:get_tags(key)
  local collections = reference:get_collections(key)

  local entry = Explorer:new(fields, tags, collections)

  ui.show_explorer_popup(entry)
end
