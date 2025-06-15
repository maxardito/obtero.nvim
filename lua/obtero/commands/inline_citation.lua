local obsidian = require "obsidian"
local obs_util = require "obsidian.util"
local obt_util = require "obtero.util"

local Search = require "obtero.search"

-- Main entry point
return function(config, _)
  local client = obsidian.get_client()

  -- Inline citation callback function
  local function inline_citation(key, reference, _)
    local citation_link = obt_util.resolve_citation_link(reference:get_reference_link(key), config)
    if citation_link ~= "" then
      obs_util.insert_text("[" .. key .. "](" .. citation_link .. ")")
    else
      obs_util.insert_text("[" .. key .. "]")
    end
  end

  -- Then call run_picker with the callback function
  Search.run_picker("Select Entry to Cite", client, inline_citation)
end
