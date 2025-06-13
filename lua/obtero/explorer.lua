local obt_util = require 'obtero.util'

---@class Contributor
---@field first_name string
---@field last_name string

---@class Explorer
---@field title string|nil
---@field authors Contributor[]|nil
---@field id string|nil
---@field type string|nil
---@field series string|nil
---@field publication string|nil
---@field volume string|nil
---@field issue string|nil
---@field page string|nil
---@field edition string|nil
---@field num_pages string|nil
---@field doi string|nil
---@field isbn string|nil
---@field issn string|nil
---@field publisher string|nil
---@field location string|nil
---@field language string|nil
---@field editors Contributor[]|nil
---@field translators Contributor[]|nil
---@field date_published string|nil
---@field date_accessed string|nil
---@field url string|nil
---@field collections string|nil
---@field tags string|nil
---@field abstract string|nil

local Explorer = {}
Explorer.__index = Explorer

-- Prettier Zotero entry types
local ZoteroDocumentTypes = {
  artwork = "Artwork",
  audioRecording = "Audio Recording",
  bill = "Legislative Bill",
  blogPost = "Blog Post",
  book = "Book",
  bookSection = "Book Chapter",
  case = "Legal Case",
  computerProgram = "Software",
  conferencePaper = "Conference Paper",
  dictionaryEntry = "Dictionary Entry",
  document = "Generic Document",
  email = "Email",
  encyclopediaArticle = "Encyclopedia Article",
  film = "Film",
  forumPost = "Forum Post",
  hearing = "Government Hearing",
  instantMessage = "Instant Message",
  interview = "Interview",
  journalArticle = "Journal Article",
  letter = "Letter",
  magazineArticle = "Magazine Article",
  manuscript = "Manuscript",
  map = "Map",
  newspaperArticle = "Newspaper Article",
  patent = "Patent",
  podcast = "Podcast",
  presentation = "Presentation",
  radioBroadcast = "Radio Broadcast",
  report = "Report",
  statute = "Statute",
  thesis = "Thesis or Dissertation",
  televisionBroadcast = "Television Broadcast",
  webpage = "Web Page"
}

---
--- Returns a Zotero entry type formatted for display
---
---@param zoteroType string
---@return string
local function _display_zotero_type(zoteroType)
  local formattedType = ZoteroDocumentTypes[zoteroType]
  local displayValue

  if formattedType then
    displayValue = formattedType
  else
    displayValue = "Unknown"
  end
  return displayValue
end

---Create a new Explorer object. Input expected to be CSL JSON
---@param fields table[]|nil
---@param tags table[]|nil
---@param collections table[]|nil
---@return Explorer
function Explorer:new(fields, tags, collections)
  if type(fields) ~= "table" then
    error("Expected table, got " .. type(fields))
  end
  if type(tags) ~= "table" then
    error("Expected table, got " .. type(tags))
  end
  if type(collections) ~= "table" then
    error("Expected table, got " .. type(collections))
  end

  fields = fields or {}
  tags = tags or {}
  collections = collections or {}

  -- Create a new merged table
  local explorer = {}
  obt_util.copy_table(fields, explorer)

  -- Copy tags and collections to explorer
  explorer.tags = obt_util.copy_array(tags)
  explorer.collections = obt_util.copy_array(collections)

  -- Copy the metatable from the fields table (assuming both share the same one)
  setmetatable(explorer, getmetatable(fields))
  setmetatable(explorer, getmetatable(collections))
  setmetatable(explorer, self)

  return explorer
end

---@class Explorer
---@field print_title fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_title(print_fn)
  if (self.title ~= "") and (self.title ~= nil) then
    print_fn("📄  title: " .. self.title)
  end
end

---@class Explorer
---@field print_authors fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_authors(print_fn)
  if self.authors ~= nil then
    print_fn("👤  authors:")
    for _, author in ipairs(self.authors) do
      if ((author.first_name ~= "") and (author.first_name ~= nil))
          and ((author.last_name ~= "") and (author.last_name ~= nil)) then
        print_fn("  - first_name: " .. author.first_name)
        print_fn("    last_name: " .. author.last_name)
      end
    end
    print_fn("")
  end
end

---@class Explorer
---@field print_id fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_id(print_fn)
  if (self.id ~= "") and (self.id ~= nil) then
    print_fn("🗝️  id: " .. self.id)
  end
  return Explorer
end

---@class Explorer
---@field print_type fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_type(print_fn)
  if (self.type ~= "") and (self.type ~= nil) then
    print_fn("🗃️  type: " .. _display_zotero_type(self.type))
  end
end

---@class Explorer
---@field print_series fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_series(print_fn)
  if (self.series ~= "") and (self.series ~= nil) then
    print_fn("📰  series: " .. self.series)
  end
end

---@class Explorer
---@field print_publication fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_publication(print_fn)
  if (self.publication ~= "") and (self.publication ~= nil) then
    print_fn("📓  publication: " .. self.publication)
  end
end

---@class Explorer
---@field print_volume fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_volume(print_fn)
  if (self.volume and self.issue and self.page ~= "")
      and (self.volume and self.issue and self.page ~= nil) then
    print_fn("📚  volume: " .. self.volume .. " | issue: " .. self.issue .. " | pages: " .. self.page)
  end
end

---@class Explorer
---@field print_edition fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_edition(print_fn)
  if (self.edition ~= "") and (self.edition ~= nil) then
    print_fn("🔢  edition: " .. self.edition)
  end
end

---@class Explorer
---@field print_pages fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_pages(print_fn)
  if (self.num_pages ~= "") and (self.num_pages ~= nil) then
    print_fn("🧻  num_pages: " .. self.num_pages)
  end
end

---@class Explorer
---@field print_doi fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_doi(print_fn)
  if (self.doi ~= "") and (self.doi ~= nil) then
    print_fn("🔗  doi: " .. self.doi)
  end
end

---@class Explorer
---@field print_isbn fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_isbn(print_fn)
  if (self.isbn ~= "") and (self.isbn ~= nil) then
    print_fn("🥭  isbn: " .. self.isbn)
  end
end

---@class Explorer
---@field print_issn fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_issn(print_fn)
  if (self.issn ~= "") and (self.issn ~= nil) then
    print_fn("🥝  issn: " .. self.issn)
  end
end

---@class Explorer
---@field print_publisher fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_publisher(print_fn)
  if (self.publisher ~= "") and (self.publisher ~= nil) then
    print_fn("🖨️  publisher: " .. self.publisher)
  end
end

---@class Explorer
---@field print_location fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_location(print_fn)
  if (self.location ~= "") and (self.location ~= nil) then
    print_fn("🗺️  location: " .. self.location)
  end
end

---@class Explorer
---@field print_language fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_language(print_fn)
  if (self.languge ~= "") and (self.language ~= nil) then
    print_fn("📖  language: " .. self.language)
  end
end

---@class Explorer
---@field print_editors fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_editors(print_fn)
  if self.editors ~= nil then
    print_fn("👓  editors:")
    for _, editor in ipairs(self.editors) do
      if ((editor.first_name ~= "") and (editor.first_name ~= nil))
          and ((editor.last_name ~= "") and (editor.last_name ~= nil)) then
        print_fn("  - first_name: " .. editor.first_name)
        print_fn("    last_name: " .. editor.last_name)
      end
    end
    print_fn("")
  end
end

---@class Explorer
---@field print_translators fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_translators(print_fn)
  if self.translators ~= nil then
    print_fn(" ✍️  translators: ")
    for _, translator in ipairs(self.translators) do
      if ((translator.first_name ~= "") and (translator.first_name ~= nil))
          and ((translator.last_name ~= "") and (translator.last_name ~= nil)) then
        print_fn("  - first_name: " .. translator.first_name)
        print_fn("    last_name: " .. translator.last_name)
      end
    end
    print_fn("")
  end
end

---@class Explorer
---@field print_date_published fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_date_published(print_fn)
  if (self.date_published ~= "") and (self.date_published ~= nil) then
    print_fn("🏺  date_published: " .. self.date_published)
  end
end

---@class Explorer
---@field print_date_accessed fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_date_accessed(print_fn)
  if (self.date_accessed ~= "") and (self.date_accessed ~= nil) then
    print_fn("🖱️  accessed: " .. self.date_accessed)
  end
end

---@class Explorer
---@field print_url fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_url(print_fn)
  if (self.url ~= "") and (self.url ~= nil) then
    print_fn("🌐  url: " .. self.url)
  end
end

---@class Explorer
---@field print_collections fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_collections(print_fn)
  if self.collections and #self.collections > 0 then
    print_fn("🗃️  collections: " .. table.concat(self.collections, ", "))
  end
end

---@class Explorer
---@field print_tags fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_tags(print_fn)
  if self.tags and #self.tags > 0 then
    print_fn("🏷️  tags: " .. table.concat(self.tags, ", "))
  end
end

---@class Explorer
---@field print_abstract fun(self: Explorer, print_fn: fun(string): nil)
function Explorer:print_abstract(print_fn)
  if (self.abstract ~= "") and (self.abstract ~= nil) then
    print_fn("🎨  abstract: " .. self.abstract:gsub("\n", " ")) -- replace newlines with spaces, indent abstract
  end
end

return Explorer
