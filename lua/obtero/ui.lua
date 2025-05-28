local popup = require("plenary.popup")

local M = {}

---
--- Turns a table with metadata belonging to a Zotero entry
--- into a UI displayed using a plenary.nvim popup
---
---@param data table A table representing the Zotero entry
local function _format_article_info(data)
  local lines = {}

  local function append(line) table.insert(lines, line) end

  append("📄  Title: " .. data.title)
  append("👤  Authors:")
  for _, author in ipairs(data.author) do
    append("    * " .. author.given .. " " .. author.family)
  end
  append("🆔  Citation Key: " .. data["citation-key"] or data.id or "")

  append("")
  append("---")
  append("")

  append("📓  Journal: " .. data["container-title"])
  append("📚  Volume: " .. data.volume .. " | Issue: " .. data.issue .. " | Pages: " .. data.page)
  append("🔗  DOI: " .. data.DOI)
  append("📅  Published: " .. table.concat(data.issued["date-parts"][1], "-"))
  append("🌐  URL: " .. data.URL)
  append("📥  Accessed: " .. table.concat(data.accessed["date-parts"][1], "-"))

  append("")
  append("---")
  append("")

  append("📝  Abstract:")
  append("    " .. data.abstract:gsub("\n", " ")) -- replace newlines with spaces, indent abstract
  append("")

  return lines
end

---
--- Find an entry by its ID in a list of tables.
---
---@param tbl table|nil A list of tables, each with an "id" field.
M.show_table_popup = function(tbl)
  if type(tbl) ~= "table" then
    error("Expected table, got " .. type(tbl))
  end

  local lines = _format_article_info(tbl)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].modifiable = false

  popup.create(bufnr, {
    title = "📘 Article Info",
    highlight = "Normal",
    line = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    border = true,
  })

  -- Optional: Enable scrolling
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<cmd>close<CR>", { silent = true, noremap = true })
end

return M
