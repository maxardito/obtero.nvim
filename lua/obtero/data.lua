---@class Contributor
---@field first_name string
---@field last_name string

---@class Data
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
---@field DOI string|nil
---@field ISBN string|nil
---@field ISSN string|nil
---@field publisher string|nil
---@field location string|nil
---@field language string|nil
---@field editors Contributor[]|nil
---@field translators Contributor[]|nil
---@field date_original string|nil
---@field date_edition string|nil
---@field date_accessed string|nil
---@field URL string|nil
---@field abstract string|nil

local Data = {}
Data.__index = Data

---Create a new Data object. Input expected to be CSL JSON
---@param o table|nil
---@return Data
function Data:new(o)
  local instance = setmetatable({}, self)
  o = o or {}
  setmetatable(o, self)

  instance.title       = o.title or nil
  instance.authors     = o.author or nil
  instance.id          = o.id or nil
  instance.type        = o.type or nil
  instance.series      = o["collection-title"] or nil
  instance.publication = o["container-title"] or nil
  instance.volume      = o.volume or nil
  instance.issue       = o.issue or nil
  instance.page        = o.page or nil
  instance.edition     = o.edition or nil
  instance.num_pages   = o["number-of-pages"] or nil
  instance.DOI         = o.DOI or nil
  instance.ISBN        = o.ISBN or nil
  instance.ISSN        = o.ISSN or nil
  instance.publisher   = o.publisher or nil
  instance.location    = o["publisher-place"] or nil
  instance.language    = o.language or nil
  instance.editors     = o.editor or nil
  instance.translators = o.translator or nil

  if o["original-date"] and o["original-date"]["date-parts"] and o["original-date"]["date-parts"][1] then
    instance.date_original = table.concat(o["original-date"]["date-parts"][1], "-")
  else
    instance.date_original = nil
  end

  -- Safely extract date_edition
  if o.issued and o.issued["date-parts"] and o.issued["date-parts"][1] then
    instance.date_edition = table.concat(o.issued["date-parts"][1], "-")
  else
    instance.date_edition = nil
  end

  -- Safely extract date_accessed
  if o.accessed and o.accessed["date-parts"] and o.accessed["date-parts"][1] then
    instance.date_accessed = table.concat(o.accessed["date-parts"][1], "-")
  else
    instance.date_accessed = nil
  end

  instance.URL      = o.URL or nil
  instance.abstract = o.abstract or nil

  return instance
end

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
local function _displayZoteroType(zoteroType)
  local formattedType = ZoteroDocumentTypes[zoteroType]
  local displayValue

  if formattedType then
    displayValue = formattedType
  else
    displayValue = "Unknown"
  end
  return displayValue
end


---@class Data
---@field print_title fun(self: Data, print_fn: fun(string): nil)
function Data:print_title(print_fn)
  if self.title ~= ("" or nil) then
    print_fn("📄  title: " .. self.title)
  end
end

---@class Data
---@field print_authors fun(self: Data, print_fn: fun(string): nil)
function Data:print_authors(print_fn)
  if self.authors ~= nil then
    print_fn("👤  authors:")
    for _, author in ipairs(self.authors) do
      if (author.given ~= ("" or nil)) and (author.family ~= ("" or nil)) then
        print_fn("  - first_name: " .. author.given)
        print_fn("    last_name: " .. author.family)
      end
    end
  end
end

---@class Data
---@field print_id fun(self: Data, print_fn: fun(string): nil)
function Data:print_id(print_fn)
  if (self.id) ~= ("" or nil) then
    print_fn("🗝️  id: " .. self.id)
  end
  return Data
end

---@class Data
---@field print_type fun(self: Data, print_fn: fun(string): nil)
function Data:print_type(print_fn)
  if self.type ~= ("" or nil) then
    print_fn("🗃️  type: " .. _displayZoteroType(self.type))
  end
end

---@class Data
---@field print_series fun(self: Data, print_fn: fun(string): nil)
function Data:print_series(print_fn)
  if self.series ~= ("" or nil) then
    print_fn("📰  series: " .. self.series)
  end
end

---@class Data
---@field print_publication fun(self: Data, print_fn: fun(string): nil)
function Data:print_publication(print_fn)
  if self.publication ~= ("" or nil) then
    print_fn("📓  publication: " .. self.publication)
  end
end

---@class Data
---@field print_volume fun(self: Data, print_fn: fun(string): nil)
function Data:print_volume(print_fn)
  if (self.volume and self.issue and self.page) ~= ("" or nil) then
    print_fn("📚  volume: " .. self.volume .. " | issue: " .. self.issue .. " | pages: " .. self.page)
  end
end

---@class Data
---@field print_edition fun(self: Data, print_fn: fun(string): nil)
function Data:print_edition(print_fn)
  if self.edition ~= ("" or nil) then
    print_fn("🔢  edition: " .. self.edition)
  end
end

---@class Data
---@field print_pages fun(self: Data, print_fn: fun(string): nil)
function Data:print_pages(print_fn)
  if self.num_pages ~= ("" or nil) then
    print_fn("🧻  num_pages: " .. self.num_pages)
  end
end

---@class Data
---@field print_doi fun(self: Data, print_fn: fun(string): nil)
function Data:print_doi(print_fn)
  if self.DOI ~= ("" or nil) then
    print_fn("🔗  DOI: " .. self.DOI)
  end
end

---@class Data
---@field print_isbn fun(self: Data, print_fn: fun(string): nil)
function Data:print_isbn(print_fn)
  if self.ISBN ~= ("" or nil) then
    print_fn("🥭  ISBN: " .. self.ISBN)
  end
end

---@class Data
---@field print_issn fun(self: Data, print_fn: fun(string): nil)
function Data:print_issn(print_fn)
  if self.ISSN ~= ("" or nil) then
    print_fn("🥝  ISSN: " .. self.ISSN)
  end
end

---@class Data
---@field print_publisher fun(self: Data, print_fn: fun(string): nil)
function Data:print_publisher(print_fn)
  if self.publisher ~= ("" or nil) then
    print_fn("🖨️  publisher: " .. self.publisher)
  end
end

---@class Data
---@field print_location fun(self: Data, print_fn: fun(string): nil)
function Data:print_location(print_fn)
  if self.location ~= ("" or nil) then
    print_fn("🗺️  location: " .. self.location)
  end
end

---@class Data
---@field print_language fun(self: Data, print_fn: fun(string): nil)
function Data:print_language(print_fn)
  if self.language ~= ("" or nil) then
    print_fn("📖  language: " .. self.language)
  end
end

---@class Data
---@field print_editors fun(self: Data, print_fn: fun(string): nil)
function Data:print_editors(print_fn)
  if self.editors ~= nil then
    print_fn("👓  editors:")
    for _, editor in ipairs(self.editors) do
      if (editor.given ~= ("" or nil)) and (editor.family ~= ("" or nil)) then
        print_fn("  - first_name: " .. editor.given)
        print_fn("    last_name: " .. editor.family)
      end
    end
  end
end

---@class Data
---@field print_translators fun(self: Data, print_fn: fun(string): nil)
function Data:print_translators(print_fn)
  if self.translators ~= nil then
    print_fn(" ✍️  translators: ")
    for _, translator in ipairs(self.translators) do
      if (translator.given ~= ("" or nil)) and (translator.family ~= ("" or nil)) then
        print_fn("  - first_name: " .. translator.given)
        print_fn("    last_name: " .. translator.family)
      end
    end
  end
end

---@class Data
---@field print_date_edition fun(self: Data, print_fn: fun(string): nil)
function Data:print_date_edition(print_fn)
  if self.date_edition ~= ("" or nil) then
    print_fn("🔮  date_edition: " .. self.date_edition)
  end
end

---@class Data
---@field print_date_origin fun(self: Data, print_fn: fun(string): nil)
function Data:print_date_origin(print_fn)
  if self.date_original ~= ("" or nil) then
    print_fn("🏺  date_original: " .. self.date_original)
  end
end

---@class Data
---@field print_date_accessed fun(self: Data, print_fn: fun(string): nil)
function Data:print_date_accessed(print_fn)
  if self.date_accessed ~= ("" or nil) then
    print_fn("🖱️  accessed: " .. self.date_accessed)
  end
end

---@class Data
---@field print_url fun(self: Data, print_fn: fun(string): nil)
function Data:print_url(print_fn)
  if self.URL ~= ("" or nil) then
    print_fn("🌐  URL: " .. self.URL)
  end
end

---@class Data
---@field print_abstract fun(self: Data, print_fn: fun(string): nil)
function Data:print_abstract(print_fn)
  if self.abstract ~= ("" or nil) then
    print_fn("🎨  abstract: " .. self.abstract:gsub("\n", " ")) -- replace newlines with spaces, indent abstract
  end
end

return Data
