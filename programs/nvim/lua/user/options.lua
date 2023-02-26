local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.signcolumn = "yes"
opt.syntax = "ON"
opt.background = "dark"
opt.termguicolors = true
opt.cursorline = true
opt.cursorlineopt = "both"
opt.guicursor = ""

opt.swapfile = false
opt.encoding = "utf8"
opt.fileencoding = "utf8"
opt.undofile = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.expandtab = true
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.completeopt = { "menuone", "noselect" }
opt.clipboard = "unnamedplus"

opt.splitright = true
opt.splitbelow = true
opt.cmdheight = 1
opt.conceallevel = 0
opt.mouse = "a"
opt.pumheight = 10
opt.showtabline = 2
opt.updatetime = 300
vim.cmd [[let netrw_browser_split=0]]
vim.cmd [[colorscheme dracula]]
