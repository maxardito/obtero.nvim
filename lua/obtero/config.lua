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

---@class ZoteroConfig
---@field path string
---@field note_path string
---@field bibstyle BibliographicStyle
config.zotero = {}

config.zotero.default = function()
  return {
    path = "~/Zotero",
    note_path = "./notes",
    bibstyle = "Chicago",
  }
end

---@class CompletionOpts
---@field picker PickerConfig
---@field zotero ZoteroConfig
---@field url_redirect boolean
config.default = function()
  return {
    picker = config.picker.default(),
    zotero = config.zotero.default(),
    url_redirect = false
  }
end

return config
