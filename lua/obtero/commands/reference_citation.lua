local obsidian = require "obsidian"
local styles = require "obtero.styles"
local obs_util = require "obsidian.util"
local obt_util = require "obtero.util"

local Search = require "obtero.search"
local Explorer = require "obtero.explorer"

-- Main entry point
return function(config, _)
  local client = obsidian.get_client()

  -- Citation reference callback function
  local function reference_citation(key, reference, _)
    local entry = Explorer:new(reference:get_fields(key), reference:get_tags(key), reference:get_collections(key))
    local citation = styles.generate_citation(entry, config)
    local citation_link = obt_util.resolve_citation_link(reference:get_reference_link(key), config)
    obs_util.insert_text("[" .. key .. "](" .. citation_link .. ") " .. citation)
  end

  -- Then call run_picker with the callback function
  Search.run_picker("Select Entry to Reference", client, reference_citation)
end
