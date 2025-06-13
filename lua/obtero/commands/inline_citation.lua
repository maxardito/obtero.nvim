-- Obsidian dependencies
local obsidian = require("obsidian")
local obs_util = require "obsidian.util"
local obt_util = require "obtero.util"
local completion = require "obtero.completion"

-- Main entry point
return function(config, _)
  local client = obsidian.get_client()

  -- Inline citation callback function
  local function inline_citation(key, reference, _)
    local citation_link = obt_util.resolve_citation_link(reference:get_reference_link(key), config)
    obs_util.insert_text("[" .. key .. "](" .. citation_link .. ")")
  end

  -- Then call run_picker with the callback function
  completion.run_picker("Select Entry to Cite", client, config, inline_citation)
end
