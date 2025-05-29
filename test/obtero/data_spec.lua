local Data = require('obtero.explorer')
local eq = assert.are.same

local function convert_contributors(contribs)
  local result = {}
  for _, c in ipairs(contribs or {}) do
    table.insert(result, {
      first_name = c.given,
      last_name = c.family,
    })
  end
  return result
end

-- TODO: Add more tests for odd JSON conditions, no authors etc
describe('Data class from JSON file', function()
  it('parses example JSON correctly', function()
    -- read the JSON file as text lines, join into string
    local json_lines = vim.fn.readfile("test/fixtures/csl_json_test.json")
    local json_text  = table.concat(json_lines, "\n")
    local data_list  = vim.fn.json_decode(json_text)

    -- take the first item
    local raw        = data_list[1]

    -- convert contributors from CSL keys to your Contributor keys
    raw.author       = convert_contributors(raw.author)
    raw.editor       = convert_contributors(raw.editor)
    raw.translator   = convert_contributors(raw.translator)

    -- create Data instance
    local data       = Data:new(raw)

    -- assertions
    eq("Dialectic of Enlightenment", data.title)
    eq("Ador44", data.id)
    eq("book", data.type)
    eq("Stanford University Press", data.publisher)
    eq("Stanford, CA", data.location)
    eq("304", data.num_pages)
    eq("1st English edition", data.edition)
    eq("https://www.sup.org/books/title/?id=151", data.url)
    eq("9780804712681", data.isbn)
    eq("en", data.language)
    eq("1944", data.date_original)
    eq("2025-5-29", data.date_accessed)

    -- check authors correctly converted
    eq(2, #data.authors)
    eq("Theodor W.", data.authors[1].first_name)
    eq("Adorno", data.authors[1].last_name)
    eq("Max", data.authors[2].first_name)
    eq("Horkheimer", data.authors[2].last_name)

    -- editor is empty list
    eq(0, #data.editors)

    -- check translator
    eq(1, #data.translators)
    eq("John", data.translators[1].first_name)
    eq("Cumming", data.translators[1].last_name)
  end)
end)
