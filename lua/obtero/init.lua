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

  -- Only copy Zotero and BBT databases to Neovim cache dir if they exist

  local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
  end

  local zotero_source = config.zotero.path .. "/zotero.sqlite"
  local better_bibtex_source = config.zotero.path .. "/better-bibtex.sqlite"

  local cache_dir = vim.fn.stdpath("cache") .. "/obtero"
  vim.fn.mkdir(cache_dir, "p")

  local zotero_dest = cache_dir .. "/zotero.sqlite"
  local better_bibtex_dest = cache_dir .. "/better-bibtex.sqlite"

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

  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      os.remove(zotero_dest)
      os.remove(better_bibtex_dest)
    end,
  })

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
