--[[
  Obtero.nvim - Initialization
  -----------------------------------

  Entry point for the Obtero Neovim plugin.

  Responsibilities:
    - Load and merge user configuration with defaults
    - Set up autocommands to manage Zotero and Better BibTeX database files
    - Register user commands dynamically from module paths
]]

local defaults = require("obtero.config").default

local M = {}

-- List of user command names mapped to their module paths
local commands = {
  ObteroDataExplorer = "obtero.commands.data_explorer",
  ObteroNewFromTemplate = "obtero.commands.new_from_template",
  ObteroInsertTags = "obtero.commands.insert_tags",
  ObteroInlineCitation = "obtero.commands.inline_citation",
  ObteroReferenceCitation = "obtero.commands.reference_citation",
}

---
--- Recursively deep-merges two tables
---
---@param t1 table: The base table.
---@param t2 table: The table to merge into t1.
---@return table: A new table containing the merged values.
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

---
--- Setup function for the Obtero plugin.
---
---@param user_config table|nil: Optional user configuration table.
function M.setup(user_config)
  local config = deep_merge(defaults(), user_config or {})

  --- Check if a file exists on disk
  ---@param path string: Path to the file.
  ---@return boolean: True if file exists, false otherwise.
  local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
  end

  -- Prepare cache directory and database paths
  local zotero_source = config.zotero.path .. "/zotero.sqlite"
  local better_bibtex_source = config.zotero.path .. "/better-bibtex.sqlite"
  local cache_dir = vim.fn.stdpath("cache") .. "/obtero"
  vim.fn.mkdir(cache_dir, "p")

  local zotero_dest = cache_dir .. "/zotero.sqlite"
  local better_bibtex_dest = cache_dir .. "/better-bibtex.sqlite"

  -- Autocommand: Copy database files to cache on VimEnter
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if file_exists(zotero_source) then
        os.execute(string.format("cp %s %s", zotero_source, zotero_dest))
      end
      if file_exists(better_bibtex_source) then
        os.execute(string.format("cp %s %s", better_bibtex_source, better_bibtex_dest))
      end
    end,
  })

  -- Autocommand: Remove cached files on VimLeave
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      os.remove(zotero_dest)
      os.remove(better_bibtex_dest)
    end,
  })

  -- Register user commands
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
