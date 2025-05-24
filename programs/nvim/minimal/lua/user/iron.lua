local iron = require("iron.core")
local view = require("iron.view")
-- local ht = require("haskell-tools")

iron.setup {
  config = {
    repl_definition = {
    },
    repl_open_cmd = view.bottom(40),
  },
}
