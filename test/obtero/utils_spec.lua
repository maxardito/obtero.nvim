local utils = require("obtero.utils")

describe("utils.find_by_id", function()
  it("returns the matching entry by ID", function()
    local entries = {
      { id = "a", value = 1 },
      { id = "b", value = 2 },
      { id = "c", value = 3 },
    }
    local result = utils.find_by_id(entries, "b")
    assert.are.same({ id = "b", value = 2 }, result)
  end)

  it("returns nil if the ID is not found", function()
    local entries = {
      { id = "a", value = 1 },
      { id = "b", value = 2 },
    }
    local result = utils.find_by_id(entries, "c")
    assert.is_nil(result)
  end)

  it("returns nil if the list is empty", function()
    local result = utils.find_by_id({}, "a")
    assert.is_nil(result)
  end)

  it("returns nil if the target_id is nil", function()
    local entries = {
      { id = "a", value = 1 },
    }
    local result = utils.find_by_id(entries, nil)
    assert.is_nil(result)
  end)
end)

describe("utils.json_to_table", function()
  it("parses a valid JSON string", function()
    local json_str = '{"foo": "bar", "num": 42}'
    local result = utils.json_to_table(json_str)
    assert.are.same({ foo = "bar", num = 42 }, result)
  end)

  it("raises an error for invalid JSON", function()
    local bad_json = '{"foo": "bar",}' -- trailing comma is invalid
    assert.has_error(function()
      utils.json_to_table(bad_json)
    end, "Invalid JSON string")
  end)

  it("parses a JSON array", function()
    local json_str = '[1, 2, 3]'
    local result = utils.json_to_table(json_str)
    assert.are.same({ 1, 2, 3 }, result)
  end)
end)
