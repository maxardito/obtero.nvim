local utils = "obsidian.utils"

local M = {}

-- TODO: Add argument checker
M.find_reference = function(reference, data)
  -- Define temporary global for custom completion
  local completion_name = "__obtero_completion_by_citation_keys"
  _G[completion_name] = function()
    return reference:get_citation_keys()
  end

  -- Prompt user for input with autocomplete
  local key = utils.input("Enter citation key (Press <Tab> for autocomplete): ", {
    completion = "customlist,v:lua." .. completion_name,
  })

  -- Clean up the temporary global
  _G[completion_name] = nil

  if not key or key == "" then
    log.warn("Aborted")
    return nil
  end

  return key
end

return M
