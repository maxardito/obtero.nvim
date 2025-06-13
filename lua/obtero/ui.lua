local popup = require("plenary.popup")

local M = {}

---
--- Turns a table with metadata belonging to a Zotero entry
--- into a UI displayed using a plenary.nvim popup
---
---@param entry Explorer A table representing the Zotero entry
local function _format_article_info(entry)
  local lines = {}

  local function append(line) table.insert(lines, line) end

  entry:print_title(append)
  entry:print_id(append)
  entry:print_authors(append)
  entry:print_editors(append)
  entry:print_translators(append)

  append("---")
  append("")

  entry:print_type(append)
  entry:print_series(append)
  entry:print_publication(append)
  entry:print_volume(append)
  entry:print_edition(append)
  entry:print_pages(append)
  entry:print_isbn(append) -- ISBN method overwrites DOI one
  entry:print_issn(append)
  entry:print_doi(append)
  entry:print_publisher(append)
  entry:print_location(append)
  entry:print_language(append)
  entry:print_date_published(append)
  entry:print_date_accessed(append)
  entry:print_url(append)

  append("")
  append("---")
  append("")

  entry:print_collections(append)
  entry:print_tags(append)

  append("")
  append("---")
  append("")

  entry:print_abstract(append)

  return lines
end

---
--- Data explorer pop up using Plenary popup
---
---@param tbl table A list of tables, each with an "id" field.
M.show_explorer_popup = function(tbl)
  local lines = _format_article_info(tbl)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].modifiable = false

  popup.create(bufnr, {
    title = "📘 Entry Info",
    highlight = "Normal",
    line = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    border = true,
  })

  -- Enable scrolling
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>close<CR>", { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<cmd>close<CR>", { silent = true, noremap = true })
end

return M
