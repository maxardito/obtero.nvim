--[[
  Obtero.nvim - Configuration
  -----------------------------------

  Provides default configuration options for the Obtero plugin.

  Responsibilities:
    - Key mappings for note-related actions
    - Zotero integration settings
    - Overall plugin defaults including optional URL redirection

  These defaults can be overridden by user-supplied configurations.
]]

local config = {}

---
--- Search Configuration
---
---@class SearchNoteMappings
---@field new_from_template string
---@field insert_inline_citation string
---@field insert_full_citation string

---@class SearchConfig
---@field note_mappings SearchNoteMappings
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

---
--- Main plugin options
---
---@alias BibliographicStyle '"Chicago"'|'"IEEE"'|'"MLA"'|'"BibTex"'

---@class ZoteroConfig
---@field path string
---@field bibstyle BibliographicStyle
config.zotero = {}

config.zotero.default = function()
  return {
    path = "~/Zotero",
    bibstyle = "Chicago",
  }
end

---
--- Complete config schema
---
---@class CompletionOpts
---@field picker SearchConfig
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
