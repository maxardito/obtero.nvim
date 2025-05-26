local M = {}

-- Optional: Support completion or range args
M.registered = {}

--- Register a new command
---@param name string
---@param config { opts: table, func: function }
M.register = function(name, config)
  M.registered[name] = config
end

--- Install all registered commands into Neovim
M.install = function()
  for name, command in pairs(M.registered) do
    vim.api.nvim_create_user_command(name, command.func, command.opts or {})
  end
end

return M
