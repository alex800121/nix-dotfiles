local indentline = require'indent_blankline'

vim.opt.list = true
-- vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

indentline.setup({
  show_end_of_line = true,
  show_current_context = true,
  show_current_context_start = true,
})
