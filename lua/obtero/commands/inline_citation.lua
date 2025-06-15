local obsidian = require "obsidian"
local completion = require "obtero.completion"
local obs_util = require "obsidian.util"
local obt_util = require "obtero.util"

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
  completion.run_picker("Select Entry to Cite", client, inline_citation)
end
