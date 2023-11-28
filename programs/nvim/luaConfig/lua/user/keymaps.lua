local whichkey = require'which-key'

whichkey.setup()

local opts = function(desc) return { noremap = true, buffer = false, desc = desc } end
vim.keymap.set("n", " ", "<Nop>", opts(''))
vim.g.mapleader = " "
vim.keymap.set("n", "L", "<Nop>", opts(''))
vim.keymap.set("n", "H", "<Nop>", opts(''))
vim.keymap.set("n", "L", "<cmd>BufferLineCycleNext<cr>", opts('Next Buffer'))
vim.keymap.set("n", "H", "<cmd>BufferLineCyclePrev<cr>", opts('Previous Buffer'))
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<cr><ESC>", opts('Escape'))
vim.keymap.set("n", "x", '"_x', opts('Delete 1 char under the cursor'))
vim.keymap.set("n", "X", '"_X', opts('Delete 1 char before the cursor'))

--normal write
vim.keymap.set("n", "<leader>W", "<cmd>w<CR>", opts('Write'))

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

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", opts('Quit'))
vim.keymap.set("n", "<leader>Q", "<cmd>qa<CR>", opts('Quit All'))
vim.keymap.set("n", "<leader>x", "<cmd>Bdelete<CR>", opts('Close Buffer'))
vim.keymap.set("n", "<leader>X", "<cmd>Bdelete!<CR>", opts('Force Close Buffer'))

vim.keymap.set("v", ">", ">gv", opts('Indent Right'))
vim.keymap.set("v", "<", "<gv", opts('Indent Left'))

vim.keymap.set("v", "p", '"_dP', opts(''))

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts('Window: Navigate Left'))
vim.keymap.set("n", "<C-j>", "<C-w>j", opts('Window: Navigate Down'))
vim.keymap.set("n", "<C-k>", "<C-w>k", opts('Window: Navigate Up'))
vim.keymap.set("n", "<C-l>", "<C-w>l", opts('Window: Navigate Right'))

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts('Window: Resize Up'))
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts('Window: Resize Down'))
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts('Window: Resize Left'))
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts('Window: Resize Right'))

vim.keymap.set("n", "<leader> ", "<cmd>nohlsearch<CR>", opts('Clear Highlight Search'))
