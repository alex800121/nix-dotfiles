local telescope = require'telescope'
local builtin = require'telescope.builtin'
local whichkey = require'which-key'

telescope.setup()
telescope.load_extension('fzf')
-- telescope.load_extension('projects')
telescope.load_extension('ht')

whichkey.add({
  {'<leader>f', group = "+Fuzzy Find..." },
})

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Fuzzy find files", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fl', builtin.live_grep, { desc = "Fuzzy live grep", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Fuzzy buffers", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Fuzzy help", noremap = true, buffer = false })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = "Fuzzy help", noremap = true, buffer = false })
-- vim.keymap.set('n', '<leader>fp', function() telescope.extensions.projects.projects({}) end, { desc = "Fuzzy project", noremap = true, buffer = false })
