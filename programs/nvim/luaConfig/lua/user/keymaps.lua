local whichkey = require'which-key'

whichkey.setup()

local opts = { noremap = true, buffer = false }
vim.keymap.set("n", " ", "<Nop>", opts)
vim.g.mapleader = " "
vim.keymap.set("n", "L", "<Nop>", opts)
vim.keymap.set("n", "H", "<Nop>", opts)
vim.keymap.set("n", "L", "<cmd>BufferLineCycleNext<cr>", opts)
vim.keymap.set("n", "H", "<cmd>BufferLineCyclePrev<cr>", opts)
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<cr><ESC>", opts)

--normal write
vim.keymap.set("n", "<leader>W", "<cmd>w<CR>", opts)

--sudo write
-- vim.keymap.set("n", "<leader>W", function()
--   vim.api.nvim_exec2([[
--     silent write !sudo tee %
--     echohl WarningMsg | echomsg "Sudo write." | echohl None
--   ]], {})
-- end, { noremap = true, buffer = false, silent = true, desc = "Sudo write" })
-- vim.api.nvim_create_autocmd({"FileChangedShell"}, { 
--   pattern = { "*" },
--   command = [[
--     let v:fcs_choice="edit"
--   ]]
-- })

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", opts)
vim.keymap.set("n", "<leader>Q", "<cmd>qa<CR>", opts)
vim.keymap.set("n", "<leader>x", "<cmd>Bdelete<CR>", opts)
vim.keymap.set("n", "<leader>X", "<cmd>Bdelete!<CR>", opts)

vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("v", "<", "<gv", opts)

vim.keymap.set("v", "p", '"_dP', opts)

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

vim.keymap.set("n", "<leader> ", "<cmd>nohlsearch<CR>", opts)
