local obsidian = require "obsidian"
local ui = require "obtero.ui"

local Search = require "obtero.search"
local Explorer = require "obtero.explorer"

-- Main entry point
return function(_, _)
  local client = obsidian.get_client()

  -- Data explorer callback function
  local function data_explorer(key, reference, _)
    local fields = reference:get_fields(key)
    local tags = reference:get_tags(key)
    local collections = reference:get_collections(key)

    local entry = Explorer:new(fields, tags, collections)

    ui.show_explorer_popup(entry)
  end

  -- Then call run_picker with the callback function
  Search.run_picker("Data Explorer", client, data_explorer)
end
