local utils = require('obtero.utils')

--- A simple ORM-like interface for querying references in Zotero + Better BibTeX SQLite databases
--- @class Entries
--- @field db DB An instance of the database wrapper
local Entries = {}
Entries.__index = Entries

-- map Zotero-style keys to Explorer fields
local field_map = {
  title = "title",
  author = "authors",
  editor = "editors",
  translator = "translators",
  abstractNote = "abstract",
  date = "date_published",
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
  itemType = "type",
  libraryCatalog = "id"
}

--- Constructor for the Entries class
--- @param db DB An instance of the DB class (SQLite wrapper)
--- @return Entries
function Entries.new(db)
  local self = setmetatable({}, Entries)
  self.db = db
  return self
end

--- Get all fields for a given citation key
--- @param citation_key string The citationKey from Better BibTeX
--- @return table[] A list of tables, each with {fieldName, value}
function Entries:get_fields(citation_key)
  local query = [[
    ATTACH DATABASE ']] .. self.db.bibtex_db_path .. [[' AS bbt;

    SELECT
      f.fieldName AS key,
      idv.value AS value
    FROM bbt.citationkey
    JOIN items i ON i.itemID = bbt.citationkey.itemID
    JOIN itemData id ON id.itemID = i.itemID
    JOIN itemDataValues idv ON idv.valueID = id.valueID
    JOIN fields f ON f.fieldID = id.fieldID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [['

    UNION ALL

    SELECT
      ct.creatorType AS key,
      c.lastName || ', ' || c.firstName AS value
    FROM bbt.citationkey
    JOIN items i ON i.itemID = bbt.citationkey.itemID
    JOIN itemCreators ic ON ic.itemID = i.itemID
    JOIN creators c ON c.creatorID = ic.creatorID
    JOIN creatorTypes ct ON ct.creatorTypeID = ic.creatorTypeID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [['
      AND ct.creatorType IN ('author', 'editor', 'translator')

    UNION ALL

    SELECT
      'itemType' AS key,
      itemTypes.typeName AS value
    FROM bbt.citationkey
    JOIN items i ON i.itemID = bbt.citationkey.itemID
    JOIN itemTypes ON itemTypes.itemTypeID = i.itemTypeID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [['

    ORDER BY key;
  ]]

  local results = self.db:query(query)
  local fields = {}

  -- Parse values into clean table
  for _, entry in ipairs(results) do
    local key = entry[1]
    local value = entry[3]
    local mapped_key = field_map[key]

    -- Parse contributors following "first_name last_name" format
    if mapped_key then
      if mapped_key == "authors" or mapped_key == "editors" or mapped_key == "translators" then
        fields[mapped_key] = fields[mapped_key] or {}
        table.insert(fields[mapped_key], utils.parse_contributor(value))
      else
        fields[mapped_key] = value
      end
    end
  end

  return fields
end

--- Get collection names for a given citation key
--- @param citation_key string
--- @return string[] A list of collection names
function Entries:get_collections(citation_key)
  local query = [[
    ATTACH DATABASE ']] .. self.db.bibtex_db_path .. [[' AS bbt;
    SELECT c.collectionName
    FROM bbt.citationkey
    JOIN collectionItems ci ON ci.itemID = bbt.citationkey.itemID
    JOIN collections c ON c.collectionID = ci.collectionID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [[';
  ]]

  local collections = utils.flatten_table(self.db:query(query))
  return collections
end

--- Get tag names for a given citation key
--- @param citation_key string
--- @return string[] A list of tag names
function Entries:get_tags(citation_key)
  local query = [[
    ATTACH DATABASE ']] .. self.db.bibtex_db_path .. [[' AS bbt;
    SELECT t.name AS tag
    FROM bbt.citationkey
    JOIN itemTags it ON it.itemID = bbt.citationkey.itemID
    JOIN tags t ON t.tagID = it.tagID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [[';
  ]]

  local tags = utils.flatten_table(self.db:query(query))
  return tags
end

-- TODO: Move to keys
--- Get all citation keys for picker autocomplete
--- @return table[] A table of citation keys
function Entries:get_citation_keys()
  local query = [[
    ATTACH DATABASE ']] .. self.db.bibtex_db_path .. [[' AS bbt;
    SELECT citationKey FROM bbt.citationkey;
  ]]

  local citations = utils.flatten_table(self.db:query(query))
  return citations
end

return Entries
