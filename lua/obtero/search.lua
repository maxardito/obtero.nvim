--[[
  Obtero.nvim - Search
  ------------------------

  Provides functionality to represent and interact with bibliographic
  search entries, particularly Zotero references, within the Obtero
  environment.

  Respobsibilities:
    - Defines a Search class encapsulating citation key, title, and authors
    - Converts raw Zotero entries into safe, formatted search entries
    - Displays entries as formatted strings suitable for pickers/UI
    - Supports user prompts for input via `vim.ui.input`
    - Integrates with a client picker UI for selecting citation keys
    - Handles callback execution on user selection

  Dependencies:
    - obsidian.log (for logging)
    - Default picker from the obsidian.nvim client
    - Neovim's native UI bnput and scheduling APIs
]]


local log = require "obsidian.log"
local obs_util = require "obtero.util"

local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"

---@class Search
---@field key string              -- The citation key.
---@field title string            -- The title of the entry.
---@field authors Contributor -- A single formatted string of authors.
local Search = {}
Search.__index = Search

---
--- Constructor for Search
---
---@param raw_entry table Raw entry data from reference:get_fields()
---@param citation_key string Citation key string
---@return Search instance
function Search:new(raw_entry, citation_key)
  local title = raw_entry.title or ""
  local authors = obs_util.contributors_to_string(raw_entry.authors)

  self = setmetatable({
    key = citation_key,
    title = title,
    authors = authors,
  }, Search)

  return self
end

---
--- Format entry as string for picker display
---
---@return string formatted display string
function Search:to_string()
  return string.format("%s - %s, %s", self.key, self.authors, self.title)
end

---
--- Prompt user with a simple input box
---
---@param prompt string Prompt text
---@param default string Default input value
---@param callback function Function called with user input
function Search.run_prompt(prompt, default, callback)
  vim.ui.input({ prompt = prompt, default = default }, function(input)
    callback(input)
  end)
end

---
--- Run picker UI to select a citation key
---
---@param prompt string Prompt text for picker
---@param client table Client object with picker method
---@param callback function Called with selected key, reference, and picker
function Search.run_picker(prompt, client, callback)
  local picker = client:picker()

  if not picker then
    log.err("No picker configured")
    return
  end

  local cache_dir = vim.fn.stdpath("cache") .. "/obtero"
  vim.fn.mkdir(cache_dir, "p")

  -- Load Zotero and BetterBibTex databases
  local reference = Entries.new(
    DB.new(
      cache_dir .. "/zotero.sqlite",
      cache_dir .. "/better-bibtex.sqlite"
    )
  )

  -- Get all citation keys
  local keys = reference:get_citation_keys()

  -- Wrap entries with Search class for safe field access
  local entries = {}

  for _, citation_key in ipairs(keys) do
    local raw_entry = reference:get_fields(tostring(citation_key))
    local entry = Search:new(raw_entry, tostring(citation_key))
    table.insert(entries, entry:to_string())
  end

  -- Run the picker and handle selection callback
  vim.schedule(function()
    picker:pick(entries, {
      prompt_title = prompt,
      callback = function(selection)
        local key = selection:match("^(%S+)")
        if callback then
          callback(key, reference, picker)
        end
      end,
    })
  end)
end

return Search
