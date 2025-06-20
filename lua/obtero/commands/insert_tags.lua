local obsidian = require "obsidian"
local obs_util = require "obsidian.util"
local obt_util = require "obtero.util"

local Search = require "obtero.search"

-- Main entry point
return function(_, _)
  local client = obsidian.get_client()

  -- Tag insert callback function
  local function tag_insert(key, reference, _)
    local tags = reference:get_tags(key)
    obs_util.insert_text(obt_util.tags_to_string(tags))
  end

  -- Then call run_picker with the callback function
  Search.run_picker("Select Entry for Tag Generation", client, tag_insert)
end
