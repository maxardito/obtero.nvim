-- Obsidian dependencies
local util = require "obsidian.util"
local log = require "obsidian.log"
local obsidian = require("obsidian")

-- Obtero dependencies
local utils = require "obtero.utils"
local ui = require "obtero.ui"
local db = require "obtero.orm.db"
local reference = require "obtero.orm.reference"

---Parses a Zotero-style flat Lua table into an Explorer object
---@param input_table table
---@return Explorer
local function parse_to_explorer(input_table)
  local explorer = {}

  -- map Zotero-style keys to Explorer fields
  local field_map = {
    title = "title",
    abstractNote = "abstract",
    date = "date_original",
    accessDate = "date_accessed",
    url = "url",
    volume = "volume",
    pages = "page",
    publicationTitle = "publication",
    DOI = "doi",
    issue = "issue",
    ISBN = "isbn",
    ISSN = "issn",
    publisher = "publisher",
    language = "language",
    place = "location",
    edition = "edition",
    numPages = "num_pages",
    series = "series",
    type = "type",
    libraryCatalog = "id"
  }

  for _, entry in ipairs(input_table) do
    local key = entry[1]
    local value = entry[3]
    local mapped_key = field_map[key]
    if mapped_key then
      explorer[mapped_key] = value
    end
  end

  return explorer
end

-- TODO: Refactor to keys.lua and make more search types
-- Factory to create a completion function with access to the dynamic zotero path
-- TODO: This should use the database citation keys and not the json
local function make_jsonkey_completion(zotero_path)
  return function(arg_lead)
    local json = vim.fn.readfile(zotero_path)
    local decoded = vim.fn.json_decode(table.concat(json, "\n"))

    local matches = {}
    for _, entry in ipairs(decoded) do
      local id = entry.id or ""
      if id:lower():find(arg_lead:lower(), 1, true) == 1 then
        table.insert(matches, id)
      end
    end
    return matches
  end
end

-- Main entry point
return function(config, data)
  local client = obsidian.get_client()
  local key
  local picker = client:picker()

  if not picker then
    log.err "No picker configured"
    return
  end

  if data.args:len() > 1 then
    log.warn "Error: Takes one argument citation key"
    return
  elseif data.args:len() == 1 then
    key = data.args
  else
    -- Create and register a temporary global completion function
    local completion_func = make_jsonkey_completion(config.zotero.path .. "/zotero.json")
    local completion_name = "__obtero_jsonkey_completion"
    _G[completion_name] = completion_func

    -- Prompt user with autocomplete
    key = util.input("Enter citation key (Press <Tab> for autocomplete): ", {
      completion = "customlist,v:lua." .. completion_name,
    })

    -- Clean up the temporary global
    _G[completion_name] = nil

    if (not key) or (key == "") then
      log.warn "Aborted"
      return
    end
  end

  -- Load Zotero JSON and find the entry
  -- local file = io.open(config.zotero.path .. "/zotero.json", "r")
  -- if not file then
  --   error("Could not open file: " .. config.zotero.path .. "/zotero.json")
  -- end
  --
  -- -- local zotero_json = file:read("*a")
  -- file:close()

  -- local zotero_tbl = utils.json_to_table(zotero_json)
  -- local entry = utils.find_by_id(zotero_tbl, key)
  --
  local ref = reference.new(
    config.zotero.path,
    db.new(config.zotero.path .. "/zotero.sqlite")
  )

  local fields = ref:get_fields(key)
  -- local tags = zotero_orm:get_tags(key)
  -- local collection = zotero_orm:get_collection(key)

  -- print("Fields:")
  -- explorer = new Explorer()
  -- ui.show_explorer_popup(explorer)
  local explorer_data = parse_to_explorer(fields)
  print(vim.inspect(explorer_data))

  ui.show_explorer_popup(parse_to_explorer((fields)))
end
