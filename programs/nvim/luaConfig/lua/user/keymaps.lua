vim.keymap.set({ "n", "v", "o" }, "<SPACE>", "<Nop>", { noremap = true, buffer = false });
vim.o.mapleader = " ";
vim.keymap.set("n", "L", ":bnext<CR>", { noremap = true, buffer = false });
vim.keymap.set("n", "H", ":bprevious<CR>", { noremap = true, buffer = false });
