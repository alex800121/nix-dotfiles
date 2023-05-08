vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Undotree', noremap = true, buffer = false }) 
vim.g.undotree_CustomUndotreeCmd = 'rightbelow vertical 32 new'
vim.g.undotree_DiffpanelHeight = 10
