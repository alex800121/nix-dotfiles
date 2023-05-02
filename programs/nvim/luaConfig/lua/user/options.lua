vim.opt.ruler = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.opt.termguicolors = true

vim.opt.mousemoveevent = true

vim.opt.scrolloff = 10

vim.opt.timeout = true
vim.opt.timeoutlen = 0

local onedark = require'onedark'
onedark.setup {
  style = 'darker'
}
onedark.load()

--vim.cmd.colorscheme("onedark")
