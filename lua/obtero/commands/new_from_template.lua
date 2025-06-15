local obsidian = require "obsidian"
local log = require "obsidian.log"
local completion = require "obtero.completion"
local styles = require "obtero.styles"
local obt_util = require "obtero.util"

local Explorer = require "obtero.explorer"

return function(config, _)
  local client = obsidian.get_client()

  if not client:templates_dir() then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  -- Entry template callback function
  local function select_entry_template(key, reference, picker)
    -- Get explorer fields, tags, and collections
    local fields = reference:get_fields(key)
    local tags = reference:get_tags(key)
    local collections = reference:get_collections(key)
    local citation_link = obt_util.resolve_citation_link(reference:get_reference_link(key), config)
    local entry = Explorer:new(fields, tags, collections)


    client.opts.templates.substitutions = {
      title = entry.title,
      authors = obt_util.contributors_to_string(entry.authors),
      id = entry.id,
      key = key,
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
      editors = obt_util.contributors_to_string(entry.editors),
      translators = obt_util.contributors_to_string(entry.translators),
      date_published = entry.date_published,
      date_accessed = entry.date_accessed,
      url = citation_link,
      collections = obt_util.list_to_string(collections),
      tags = obt_util.tags_to_string(tags),
      abstract = entry.abstract,
      citation = styles.generate_citation(entry, config) or ""
    }

    -- Keep from going to insert mode and removing vim markdown formatting
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', false)

    -- Call a picker again to select a template
    picker:find_templates {
      callback = function(name)
        -- Generate the note at the specified path
        completion.run_prompt("🗃️ Path to new note: ", "ingestion/" .. key .. ".md", function(path)
          -- Create the note and populate with tags
          local note = client:create_note { title = path, no_write = true, tags = tags }

          -- Open the note in a new buffer.
          client:open_note(note, { sync = true })

          -- Write the note
          client:write_note_to_buffer(note, { template = name })

          -- Go to top of the nenw file
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>gg", true, false, true), 'n', false)
        end)
      end,
    }
  end

  -- Then call run_picker with the callback function
  completion.run_picker("Select Entry for Template", client, select_entry_template)
end
