-- Obsidian dependencies
local obsidian = require("obsidian")
-- NOTE: There is an obsidian utils too...
local utils = require "obsidian.util"
local log = require "obsidian.log"

-- Obtero dependencies
local DB = require "obtero.orm.db"
local Entries = require "obtero.orm.entries"

-- local htmlparser = require("htmlparser")
-- local urldecode = require("socket.url").unescape -- For decoding URL-encoded citation metadata

-- Helper: Convert citation JSON to readable citation key
local function parse_citation_metadata(encoded)
  local ok, decoded = pcall(urldecode, encoded)
  if not ok then return "(invalid citation)" end
  local ok2, json = pcall(function() return assert(load("return " .. decoded))() end)
  if ok2 and json.citationItems and json.citationItems[1] then
    return "(" .. (json.citationItems[1]["uris"][1]:match("items/(.+)$") or "citation") .. ")"
  else
    return "(citation)"
  end
end

-- Recursive HTML-to-Markdown conversion
local function html_to_md(node)
  local md = {}

  for _, child in ipairs(node.childNodes or {}) do
    if type(child) == "string" then
      table.insert(md, child)
    else
      local tag = child.name
      local inner = html_to_md(child)

      if tag == "h2" then
        table.insert(md, "## " .. inner .. "\n")
      elseif tag == "p" then
        table.insert(md, inner .. "\n")
      elseif tag == "em" then
        table.insert(md, "*" .. inner .. "*")
      elseif tag == "code" then
        table.insert(md, "`" .. inner .. "`")
      elseif tag == "pre" then
        table.insert(md, "```\n" .. inner .. "\n```\n")
      elseif tag == "blockquote" then
        table.insert(md, "> " .. inner:gsub("\n", "\n> ") .. "\n")
      elseif tag == "a" then
        local href = child.attributes.href or "#"
        table.insert(md, "[" .. inner .. "](" .. href .. ")")
      elseif tag == "ol" then
        for i, li in ipairs(child:getElementsByTagName("li")) do
          table.insert(md, i .. ". " .. html_to_md(li))
        end
      elseif tag == "span" and child.attributes["class"] == "citation" then
        local citation = child.attributes["data-citation"]
        table.insert(md, parse_citation_metadata(citation))
      else
        table.insert(md, inner) -- fallback
      end
    end
  end

  return table.concat(md)
end

-- MAIN: parse the Zotero HTML blob
local function parse_zotero_note(html)
  local root = htmlparser.parse(html)
  return html_to_md(root)
end

-- Main entry point
return function(config, data)
  local client = obsidian.get_client()
  local key
  local picker = client:picker()

  local reference = Entries.new(
    DB.new(
      config.zotero.path .. "/zotero.sqlite",
      config.zotero.path .. "/better-bibtex.sqlite"
    )
  )

  if not picker then
    log.err "No picker configured"
    return
  end

  if data.args:len() > 1 then
    log.warn "Error: Takes one argument citation key"
    return
  elseif data.args:len() == 1 then
    key = data.args
  else
    -- TODO: More complete functions, plus the current one doesn't really work
    local completion_func = function() return reference:get_citation_keys() end
    local completion_name = "__obtero_completion_by_citation_keys"
    _G[completion_name] = completion_func

    -- Prompt user with autocomplete
    key = utils.input("Enter citation key (Press <Tab> for autocomplete): ", {
      completion = "customlist,v:lua." .. completion_name,
    })

    -- Clean up the temporary global
    _G[completion_name] = nil

    if (not key) or (key == "") then
      log.warn "Aborted"
      return
    end
  end

  local notes = reference:get_notes(key)
  utils.insert_text(parse_zotero_note(notes))
end
