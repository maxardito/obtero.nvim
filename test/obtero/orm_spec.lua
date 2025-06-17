require "plenary"

local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"
local test_utils = require "test_utils"
local db_path = "test/fixtures/sqlite"

---
--- Test basic database retrieval and field formatting from an entry. Currently only
--- tested on Journal and Book entry types in Zotero.
---
describe("🔢 Database / Entry Tests: \n", function()
  local journal_fields, journal_tags, journal_collections
  local mock_journal_fields, mock_journal_tags
  local book_fields, book_tags, book_collections
  local mock_book_fields, mock_book_tags
  local keys, mock_keys, mock_collections

  before_each(function()
    local reference = Entries.new(
      DB.new(
        db_path .. "/zotero.sqlite",
        db_path .. "/better-bibtex.sqlite"
      )
    )

    local journal_key = "ALM19"
    journal_fields = reference:get_fields(journal_key)
    journal_tags = reference:get_tags(journal_key)
    journal_collections = reference:get_collections(journal_key)
    keys = reference:get_citation_keys()

    local book_key = "AH16"
    book_fields = reference:get_fields(book_key)
    book_tags = reference:get_tags(book_key)
    book_collections = reference:get_collections(book_key)

    mock_journal_fields = test_utils.read_json("./test/fixtures/json/journal_entry.json")
    mock_journal_tags = { "Signal-Processing", "Wavelets" }

    mock_book_fields = test_utils.read_json("./test/fixtures/json/book_entry.json")
    mock_book_tags = { "Frankfurt-School", "Critical-Theory" }

    mock_collections = { "Test-Library" }
    mock_keys = { book_key, journal_key }
  end)

  it("================ 📓 Journal - Field Entries ================", function()
    test_utils.assert_equal_table(journal_fields, mock_journal_fields)
  end)

  it("================ 📓 Journal - Tags ================", function()
    test_utils.assert_equal_table(journal_tags, mock_journal_tags)
  end)

  it("================ 📓 Journal - Collections ================", function()
    test_utils.assert_equal_table(journal_collections, mock_collections)
  end)

  it("================ 📘 Book - Field Entries ================", function()
    test_utils.assert_equal_table(book_fields, mock_book_fields)
  end)

  it("================ 📘 Book - Tags ================", function()
    test_utils.assert_equal_table(book_tags, mock_book_tags)
  end)

  it("================ 📘 Book - Collections ================", function()
    test_utils.assert_equal_table(book_collections, mock_collections)
  end)

  it("================ 🗝️ Citation Keys ================", function()
    test_utils.assert_equal_table(keys, mock_keys)
  end)
end)
