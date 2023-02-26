local maps = vim.keymap.set
local opts = { noremap = true, silent = true }

maps("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

maps('n', 'x', '"_x', opts)
maps('n', 'X', '"_X', opts)

maps('n', 'L', ':bnext<CR>', opts)
maps('n', 'H', ':bprevious<CR>', opts)
maps('n', '<leader>x', ':Bdelete<CR>', opts)
maps('n', '<leader>q', ':qa<CR>', opts)

maps('v', '>', '>gv', opts)
maps('v', '<', '<gv', opts)


maps('n', '<leader>f', ':Telescope find_files<CR>', opts)
maps('n', '<leader>g', ':Telescope live_grep<CR>', opts)

maps('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
maps('n', '<leader>p', ':NvimTreeToggle<CR>', opts)
