require('vim._core.ui2').enable({ enable = true })
vim.loader.enable()

require'user.options'
require'user.keymaps'
require'user.telescope'
require'user.lsp'
