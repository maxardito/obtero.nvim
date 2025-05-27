-- Obsidian dependencies
local util = require "obsidian.util"
local log = require "obsidian.log"
local obsidian = require("obsidian")

-- Obtero dependencies
local template = require "obtero.template"

return function(config, data)
  local client = obsidian.get_client()

  if not client:templates_dir() then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  ---@type obsidian.Note
  local note
  if data.args and data.args:len() > 0 then
    note = client:create_note { title = data.args, json = data.args, entry = data.args, no_write = true }
  else
    local title = util.input("Enter title or path (optional): ", { completion = "file" })
    -- local json = util.input("Enter path to the json to populate: ", { completion = "file" })
    --FIXME: completion should be custom list like this
    -- local entry = util.input("Enter entry: ", { completion = "customlist,v:lua.jsonkey_completion" })
    -- local entry = util.input("Enter entry: ")
    if not title then
      log.warn "Aborted"
      return
    elseif title == "" then
      title = nil
    end
    note = client:create_note { title = title, no_write = true }
  end

  -- Open the note in a new buffer.
  client:open_note(note, { sync = true })

  picker:find_templates {
    callback = function(name)
      client:write_note_to_buffer(note, { template = name })
    end,
  }
  template.substitute_json_variables()
end
