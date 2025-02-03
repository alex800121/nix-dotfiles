local iron = require("iron.core")
-- local ht = require("haskell-tools")

iron.setup {
  config = {
    repl_definition = {
      haskell = {
        command = function(meta)
          local file = vim.api.nvim_buf_get_name(meta.current_bufnr)
          -- call `require` in case iron is set up before haskell-tools
          return ht.repl.mk_repl_cmd(file)
        end,
      },
    },
  },
}
