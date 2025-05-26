-- local util = require "obsidian.util"
--
-- local M = {}
--
-- ---@param text string
-- ---@param client obsidian.Client
-- ---@param note obsidian.Note
-- ---@param json? string  -- path to JSON file
-- ---@param entry? string  -- entry name
-- ---@return string
-- M.substitute_json_variables = function(text, client, note, json, entry)
--   local methods = vim.deepcopy(client.opts.templates.substitutions or {})
--
--   -- Load substitutions from JSON file if provided
--   if json then
--     local file = io.open(json, "r")
--     if file then
--       local content = file:read("*a")
--       file:close()
--       local ok, decoded = pcall(vim.json.decode, content)
--       if ok and type(decoded) == "table" then
--         for k, v in pairs(decoded) do
--           if type(v) == "string" then
--             methods[k] = v
--           end
--         end
--       else
--         vim.notify("Failed to decode JSON from " .. json, vim.log.levels.ERROR)
--       end
--     else
--       vim.notify("Could not open JSON file: " .. json, vim.log.levels.WARN)
--     end
--   end
--
--   -- Built-in substitutions
--   methods["date"] = methods["date"] or function()
--     local fmt = client.opts.templates.date_format or "%Y-%m-%d"
--     return os.date(fmt)
--   end
--
--   methods["time"] = methods["time"] or function()
--     local fmt = client.opts.templates.time_format or "%H:%M"
--     return os.date(fmt)
--   end
--
--   methods["title"] = methods["title"] or (note.title or note:display_name())
--   methods["id"] = methods["id"] or tostring(note.id)
--   if note.path and not methods["path"] then
--     methods["path"] = tostring(note.path)
--   end
--
--   -- Replace known variables
--   for key, subst in pairs(methods) do
--     for m_start, m_end in util.gfind(text, "{{" .. key .. "}}", nil, true) do
--       local value = type(subst) == "string" and subst or subst()
--       methods[key] = value
--       text = string.sub(text, 1, m_start - 1) .. value .. string.sub(text, m_end + 1)
--     end
--   end
--
--   -- Prompt for unknown variables
--   for m_start, m_end in util.gfind(text, "{{[^}]+}}") do
--     local key = util.strip_whitespace(string.sub(text, m_start + 2, m_end - 2))
--     local value = util.input(string.format("Enter value for '%s' (<cr> to skip): ", key))
--     if value and #value > 0 then
--       text = string.sub(text, 1, m_start - 1) .. value .. string.sub(text, m_end + 1)
--     end
--   end
--
--   return text
-- end
--
-- return M

-- local util = require "obsidian.util"

local M = {}

M.substitute_json_variables = function()
  vim.notify("RONNIE DOBBS! RONNIE DOBBS!", vim.log.levels.INFO)
end

return M
