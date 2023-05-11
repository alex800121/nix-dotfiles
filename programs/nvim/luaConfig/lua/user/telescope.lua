local telescope = require'telescope' 
local builtin = require'telescope.builtin'

telescope.setup()
telescope.load_extension('fzf')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Fuzzy find files", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Fuzzy grep", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Fuzzy buffers", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Fuzzy help", noremap = true, buffer = false })
