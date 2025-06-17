--[[
  Obtero.nvim - Initialization (Styles)

  This module manages bibliographic citation formatting styles
  for Obtero by aggregating multiple style generators and providing
  a unified interface for citation generation.

  Supported Citation Styles:
    - IEEE
    - Chicago
    - MLA

  Responsibilities:
    - Imports individual style formatting modules
    - Exposes a `generate_citation` function that formats an entry
      according to the user's configured bibliography style

  Dependencies:
    - obsidian.log (for logging)
]]

local log = require "obsidian.log"
local ieee = require "obtero.styles.ieee"
local chicago = require "obtero.styles.chicago"
local mla = require "obtero.styles.mla"

local styles = {
  ieee = ieee.ieee,
  chicago = chicago.chicago,
  mla = mla.mla,
}

---
--- Generates a formatted citation string based on the configured bibliography style.
---
---@param entry table: A table representing the bibliographic entry to format.
---@return string|nil: A formatted citation string if the style is valid; otherwise, nil.
local function generate_citation(entry, config)
  if config.zotero.bibstyle == "chicago" then
    return styles.chicago(entry)
  elseif config.zotero.bibstyle == "mla" then
    return styles.mla(entry)
  elseif config.zotero.bibstyle == "ieee" then
    return styles.ieee(entry)
  else
    log.err("Error: Please set a valid bibstyle in your nvim config. Valid options: ieee, mla, chicago")
    return nil
  end
end

-- Export the style table and the citation generator function
styles.generate_citation = generate_citation

return styles
