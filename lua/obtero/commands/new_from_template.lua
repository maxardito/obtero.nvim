-- Obsidian dependencies
local utils = require "obsidian.util"
local obt_utils = require "obtero.utils"
local log = require "obsidian.log"
local obsidian = require("obsidian")
local Explorer = require("obtero.explorer")

-- Obtero dependencies
local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"

return function(config, data)
  local client = obsidian.get_client()

  if not client:templates_dir() then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  local reference = Entries.new(
    DB.new(
      config.zotero.path .. "/zotero.sqlite",
      config.zotero.path .. "/better-bibtex.sqlite"
    )
  )
  ---@type obsidian.Note
  local note
  if data.args and data.args:len() > 0 then
    note = client:create_note { title = data.args, key = data.args, no_write = true }
  else
    local title = utils.input("Enter title or path (optional): ", { completion = "file" })
    --- Create and register a temporary global completion function
    -- TODO: More complete functions
    local completion_func = function() return reference:get_citation_keys() end
    local completion_name = "__obtero_completion_by_citation_keys"
    _G[completion_name] = completion_func

    --- Prompt user with autocomplete
    local key = utils.input("Enter citation key (Press <Tab> for autocomplete): ", {
      completion = "customlist,v:lua." .. completion_name,
    })

    if (not key) or (key == "") then
      log.warn "Aborted"
      return
    end

    if not title then
      log.warn "Aborted"
      return
    elseif title == "" then
      title = nil
    end

    -- Get explorer fields, tags, and collections
    local fields = reference:get_fields(key)
    local tags = reference:get_tags(key)
    local collections = reference:get_collections(key)
    local citation_link = reference:get_reference_link(key)
    local entry = Explorer:new(fields, tags, collections)

    -- TODO: URL-first mode v.s. PDF/URL mode should be a config option
    -- NOTE: Recommend obsidian.nvim URL mode code snipit
    if (citation_link.file_path ~= "") and (citation_link.file_path ~= nil) then
      citation_link = "file:" .. config.zotero.path .. "/" .. citation_link.file_path:gsub(" ", "%%20")
    else
      citation_link = citation_link.url
    end

    client.opts.templates.substitutions = {
      title = entry.title,
      authors = obt_utils.contributors_to_string(entry.authors),
      id = entry.id,
      type = entry.type,
      series = entry.series,
      publication = entry.publication,
      volume = entry.volume,
      issue = entry.issue,
      page = entry.page,
      edition = entry.edition,
      num_pages = entry.num_pages,
      doi = entry.doi,
      isbn = entry.isbn,
      issn = entry.issn,
      publisher = entry.publisher,
      location = entry.location,
      language = entry.language,
      editors = obt_utils.contributors_to_string(entry.editors),
      translators = obt_utils.contributors_to_string(entry.translators),
      date_published = entry.date_published,
      date_accessed = entry.date_accessed,
      url = citation_link,
      collections = obt_utils.list_to_string(collections),
      tags = obt_utils.tags_to_string(tags),
      abstract = entry.abstract,
    }

    -- TODO: Refactor into something like this
    -- Parse substitutions from entry object
    -- local substitutions = {}
    --
    -- for k, v in pairs(entry) do
    --   if key == "authors" or key == "editors" or key == "translators" then
    --     substitutions[k] = obt_utils.contributors_to_string(v)
    --   else
    --     substitutions[k] = v
    --   end
    -- end
    --
    -- -- Load substitutions into the config opts
    -- client.opts.templates.substitutions = substitutions


    note = client:create_note { title = title, no_write = true }
  end

  -- Open the note in a new buffer.
  client:open_note(note, { sync = true })

  picker:find_templates {
    callback = function(name)
      client:write_note_to_buffer(note, { template = name })
    end,
  }
end
