local ieee = require("obtero.styles.ieee")
local chicago = require("obtero.styles.chicago")
local mla = require("obtero.styles.mla")
local apa = require("obtero.styles.apa")

-- BUG: There are definitely some errors with punctuation and commas in the style reference generators that need to be fixed

local styles = {
  ieee = ieee.ieee,
  chicago = chicago.chicago,
  mla = mla.mla,
  apa = apa.apa
}

--- Generates a formatted citation string based on the configured bibliography style.
--
-- @param entry table: A table representing the bibliographic entry to format.
-- @return string|nil: A formatted citation string if the style is valid; otherwise, nil.
local function generate_citation(entry, config)
  if config.zotero.bibstyle == "chicago" then
    return styles.chicago(entry)
  elseif config.zotero.bibstyle == "apa" then
    return styles.apa(entry)
  elseif config.zotero.bibstyle == "mla" then
    return styles.mla(entry)
  elseif config.zotero.bibstyle == "ieee" then
    return styles.ieee(entry)
  else
    log.err("Error: Please set a valid bibstyle in your nvim config. Valid options: chicago, ieee, apa, mla")
    return nil
  end
end

-- Export the style table and the citation generator function
styles.generate_citation = generate_citation

return styles
