-- Obsidian dependencies
local obsidian = require("obsidian")
-- NOTE: There is an obsidian utils too...
local utils = require "obsidian.util"
local log = require "obsidian.log"

-- Obtero dependencies
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

  -- TODO: More complete functions, plus the current one doesn't really work
  local completion_func = function() return reference:get_citation_keys() end
  local completion_name = "__obtero_completion_by_citation_keys"
  _G[completion_name] = completion_func

  -- Prompt user with autocomplete
  key = utils.input("Enter citation key (Press <Tab> for autocomplete): ", {
    completion = "customlist,v:lua." .. completion_name,
  })

  -- Clean up the temporary global
  _G[completion_name] = nil

  if (not key) or (key == "") then
    log.warn "Aborted"
    return
  end

  local tags = utils.tags_to_string(reference:get_tags(key))

  utils.insert_text(tags)
end
