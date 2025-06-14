local defaults = require("obtero.config").default

local M = {}

local commands = {
  ObteroDataExplorer = "obtero.commands.data_explorer",
  ObteroNewFromTemplate = "obtero.commands.new_from_template",
  ObteroInsertTags = "obtero.commands.insert_tags",
  ObteroInlineCitation = "obtero.commands.inline_citation",
  ObteroReferenceCitation = "obtero.commands.reference_citation",
}

-- Deep merge
local function deep_merge(t1, t2)
  local result = vim.deepcopy(t1)
  for k, v in pairs(t2 or {}) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = deep_merge(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

M.setup = function(user_config)
  local config = deep_merge(defaults(), user_config or {})

  -- Copy Zotero and BBT databases to a tmp directory each time an Obsidian vault is opened

  -- Load commands
  for name, module_path in pairs(commands) do
    local ok, fn = pcall(require, module_path)
    if ok and type(fn) == "function" then
      vim.api.nvim_create_user_command(name, function(data)
        fn(config, data)
      end, {
        nargs = "*",
        desc = "Obtero command: " .. name,
      })
    else
      vim.notify("Obtero: Failed to load " .. module_path, vim.log.levels.ERROR)
    end
  end
end

return M
