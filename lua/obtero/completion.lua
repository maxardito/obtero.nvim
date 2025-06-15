local log = require "obsidian.log"
local obs_util = require "obtero.util"

local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"

local M = {}

M.run_prompt = function(prompt, default, callback)
  vim.ui.input({ prompt = prompt, default = default }, function(input)
    callback(input)
  end)
end

M.run_picker = function(prompt, client, callback)
  local picker = client:picker()

  if not picker then
    log.err("No picker configured")
    return
  end

  local cache_dir = vim.fn.stdpath("cache") .. "/obtero"
  vim.fn.mkdir(cache_dir, "p")

  -- Load the Zotero and BetterBibTex databases
  local reference = Entries.new(
    DB.new(
      cache_dir .. "/zotero.sqlite",
      cache_dir .. "/better-bibtex.sqlite"
    )
  )

  -- Get all the citation keys
  local keys = reference:get_citation_keys()

  -- Get search terms (title and author) from the citation keys
  local entries = {}

  -- REFACTOR: Untyped variables straight from the Entries class should be put through an intermediary class just for
  -- the picker
  for _, citation_key in ipairs(keys) do
    local fields = reference:get_fields(tostring(citation_key))
    local title = (fields and fields.title) or ""

    local authors = obs_util.contributors_to_string(fields.authors or {})

    local cmp_entry_str = citation_key .. " - " .. authors .. ", " .. title
    table.insert(entries, cmp_entry_str)
  end

  -- Run the picker and prep the callback function
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

return M
