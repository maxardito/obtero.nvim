require "plenary"

local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"
local Explorer = require "obtero.explorer"
local ieee = require "obtero.styles.ieee"
local chicago = require "obtero.styles.chicago"
local mla = require "obtero.styles.mla"
local test_utils = require "test_utils"
local db_path = "test/fixtures/sqlite"

---
--- Test bibliographic formatting from an entry. Currently only
--- tested on Journal and Book entry types in Zotero formatted using
--- Chicago, IEEE, and MLA styles.
---
describe("💅 Style Tests: \n", function()
  local journal_entry, book_entry

  before_each(function()
    local reference = Entries.new(
      DB.new(
        db_path .. "/zotero.sqlite",
        db_path .. "/better-bibtex.sqlite"
      )
    )

    local journal_key = "ALM19"

    journal_entry = Explorer:new(reference:get_fields(journal_key), reference:get_tags(journal_key),
      reference:get_collections(journal_key))

    local book_key = "AH16"

    book_entry = Explorer:new(reference:get_fields(book_key), reference:get_tags(book_key),
      reference:get_collections(book_key))
  end)

  it("================ 🖥️ IEEE - Journal ================", function()
    local citation = ieee.ieee(journal_entry)
    local mock_citation =
    "J. Andén, V. Lostanlen, and S. Mallat, \"Joint Time-Frequency Scattering,\" *IEEE Transactions on Signal Processing*, vol. 67, no. 14, pp. 3704-3718, May 24, 2019doi: 10.1109/TSP.2019.2918992. [Online]. Available: [https://ieeexplore.ieee.org/document/8721532](https://ieeexplore.ieee.org/document/8721532). Accessed Jun. 15, 2025."

    test_utils.assert_equal_string(citation, mock_citation)
  end)

  it("================ 🖥️ IEEE - Book ================", function()
    local citation = ieee.ieee(book_entry)
    local mock_citation =
    "T. Adorno, and M. Horkheimer, *Dialectics of Enlightenment*, Test Edition. New York, NY: Verso, Sep. 2016."

    test_utils.assert_equal_string(citation, mock_citation)
  end)

  it("================ 🗣️ MLA - Journal ================", function()
    local citation = mla.mla(journal_entry)
    local mock_citation =
    "Andén, Joakim, Lostanlen, Vincent, and Mallat, Stéphane. \"Joint Time-Frequency Scattering.\" *IEEE Transactions on Signal Processing*, vol. 67, no. 14, 2019, pp. 3704-3718. https://doi.org/10.1109/TSP.2019.2918992."

    test_utils.assert_equal_string(citation, mock_citation)
  end)

  it("================ 🗣️ MLA - Book ================", function()
    local citation = mla.mla(book_entry)
    local mock_citation =
    "Adorno, Theodor, and Max Horkheimer. *Dialectics of Enlightenment*. Verso, 2016."

    test_utils.assert_equal_string(citation, mock_citation)
  end)

  it("================ 🌆 Chicago - Journal ================", function()
    local citation = chicago.chicago(journal_entry)
    local mock_citation =
    "Andén, Joakim, Vincent Lostanlen, and Stéphane Mallat. 2019. \"Joint Time-Frequency Scattering.\" *IEEE Transactions on Signal Processing* 67, no. 14 : 3704-3718. https://doi.org/10.1109/TSP.2019.2918992."

    test_utils.assert_equal_string(citation, mock_citation)
  end)

  it("================ 🌆 Chicago - Book ================", function()
    local citation = chicago.chicago(book_entry)
    print("BOOK: " .. citation)
    local mock_citation =
    "Adorno, Theodor, and Max Horkheimer. 2016. *Dialectics of Enlightenment*. New York, NY: Verso."

    test_utils.assert_equal_string(citation, mock_citation)
  end)
end)
