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

vim.opt.updatetime = 100

vim.opt.clipboard = 'unnamedplus'
vim.opt.conceallevel = 0

vim.opt.hlsearch = true

vim.opt.showmode = false

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.signcolumn = "yes"

vim.opt.cursorline = true
-- local onedark = require'onedark'
-- onedark.setup {
--   style = 'darker'
-- }
-- onedark.load()
vim.cmd.colorscheme('gruvbox')
