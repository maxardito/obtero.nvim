local ieee = require("obtero.styles.ieee")
local chicago = require("obtero.styles.chicago")
local mla = require("obtero.styles.mla")
local apa = require("obtero.styles.apa")

-- BUG: There are definitely some errors with punctuation and commas in the style reference generators that need to be fixed

local styles = {
  ieee = ieee.ieee,
  chicago = chicago.chicago,
  mla = mla.mla,
  apa = apa.apa
}

return styles
