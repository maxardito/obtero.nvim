-- ~/labor/obtero.nvim/lua/obtero/config.lua
local config = {}

--- Picker Configuration
---@class PickerNoteMappings
---@field new_from_template string
---@field insert_inline_citation string
---@field insert_full_citation string

---@class PickerConfig
---@field note_mappings PickerNoteMappings

config.picker = {}

config.picker.default = function()
  return {
    note_mappings = {
      new_from_template = "<C-t>",
      insert_inline_citation = "<C-l>",
      insert_full_citation = "<C-p>",
    },
  }
end

--- Main plugin options
---@alias BibliographicStyle '"Chicago"'|'"IEEE"'|'"APA"'|'"MLA"'|'"BibTex"'

---@class OptsConfig
---@field zotero_path string
---@field note_path string
---@field bib_style BibliographicStyle

config.opts = {}

config.opts.default = function()
  return {
    zotero_path = "~",
    note_path = "./notes",
    bib_style = "Chicago",
  }
end

---@class CompletionOpts
---@field picker PickerConfig
---@field opts OptsConfig

config.default = function()
  return {
    picker = config.picker.default(),
    opts = config.opts.default(),
  }
end

return config
