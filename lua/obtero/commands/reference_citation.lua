-- Obsidian dependencies
local obsidian = require("obsidian")
local utils = require "obsidian.util"
local obt_utils = require "obtero.utils"
local log = require "obsidian.log"
local Explorer = require "obtero.explorer"
local styles = require "obtero.styles"
local completion = require "obtero.completion"

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

  -- TODO: More complete functions
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

  local fields = reference:get_fields(key)
  local tags = reference:get_tags(key)
  local collections = reference:get_collections(key)

  local entry = Explorer:new(fields, tags, collections)

  local citation
  if (config.zotero.bibstyle == "chicago") then
    citation = styles.chicago(entry)
  elseif (config.zotero.bibstyle == "apa") then
    citation = styles.apa(entry)
  elseif (config.zotero.bibstyle == "mla") then
    citation = styles.mla(entry)
  elseif (config.zotero.bibstyle == "ieee") then
    citation = styles.ieee(entry)
  else
    log.err "Error: Please set a valid bibstyle in your nvim config. Valid options: chicago, ieee, apa, mla"
    return
  end

  local citation_link = obt_utils.resolve_citation_link(reference:get_reference_link(key), config)

  utils.insert_text("[" .. key .. "](" .. citation_link .. ")" .. citation)
end
