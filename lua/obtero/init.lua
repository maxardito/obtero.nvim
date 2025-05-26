local M = {}

--- Map of command names to module paths
local commands = {
  ObteroPopulate = "obtero.commands.obtero_populate",
}

M.install = function(client)
  for name, module_path in pairs(commands) do
    local ok, fn = pcall(require, module_path)
    if ok and type(fn) == "function" then
      vim.api.nvim_create_user_command(name, function(data)
        fn(client, data)
      end, {
        nargs = "*",
        desc = "Auto-registered command: " .. name,
      })
    else
      vim.notify("Failed to load " .. module_path, vim.log.levels.ERROR)
    end
  end
end

return M
