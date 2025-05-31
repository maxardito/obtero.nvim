-- Reference.lua

-- TODO: Make the headers reference the types
--# Reference
-- A simple ORM-like interface for querying references in Zotero + Better BibTeX SQLite databases

local Reference = {}
Reference.__index = Reference

-- Constructor
-- @param db_path string: Path to the Zotero main database directory (not including /better-bibtex.sqlite)
-- @param db object: An instance of SqliteWrapper
function Reference.new(db_path, db)
  local self = setmetatable({}, Reference)
  self.db_path = db_path
  self.db = db
  return self
end

-- Get fields for a given entry ID
-- @param citation_key string: The citationKey from better-bibtex
-- @return table: A list of {fieldName, value} tables
function Reference:get_fields(citation_key)
  local query = [[
    ATTACH DATABASE ']] .. self.db_path .. [[/better-bibtex.sqlite' AS bbt;
    SELECT
      f.fieldName,
      idv.value
    FROM bbt.citationkey
    JOIN items i ON i.itemID = bbt.citationkey.itemID
    JOIN itemData id ON id.itemID = i.itemID
    JOIN itemDataValues idv ON idv.valueID = id.valueID
    JOIN fields f ON f.fieldID = id.fieldID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [[';
  ]]
  return self.db:query(query)
end

-- Get collections for a given entry ID
-- @param citation_key string
-- @return table: A list of collection names
function Reference:get_collections(citation_key)
  local query = [[
    ATTACH DATABASE ']] .. self.db_path .. [[/better-bibtex.sqlite' AS bbt;
    SELECT c.collectionName
    FROM bbt.citationkey
    JOIN collectionItems ci ON ci.itemID = bbt.citationkey.itemID
    JOIN collections c ON c.collectionID = ci.collectionID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [[';
  ]]
  return self.db:query(query)
end

-- Get tags for a given entry ID
-- @param citation_key string
-- @return table: A list of tag names
function Reference:get_tags(citation_key)
  local query = [[
    ATTACH DATABASE ']] .. self.db_path .. [[/better-bibtex.sqlite' AS bbt;
    SELECT t.name AS tag
    FROM bbt.citationkey
    JOIN itemTags it ON it.itemID = bbt.citationkey.itemID
    JOIN tags t ON t.tagID = it.tagID
    WHERE bbt.citationkey.citationKey = ']] .. citation_key .. [[';
  ]]
  return self.db:query(query)
end

return Reference
