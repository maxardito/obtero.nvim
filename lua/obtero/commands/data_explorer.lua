-- Obsidian dependencies
local obsidian = require "obsidian"
local completion = require "obtero.completion"
local ui = require "obtero.ui"

local Explorer = require "obtero.explorer"

-- Main entry point
return function(config, _)
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
  completion.run_picker("Data Explorer", client, config, data_explorer)
end
