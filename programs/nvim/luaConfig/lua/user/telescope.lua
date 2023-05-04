local telescope = require'telescope' 
local builtin = require'telescope.builtin'

telescope.setup()
telescope.load_extension('fzf')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { noremap = true, buffer = false })
