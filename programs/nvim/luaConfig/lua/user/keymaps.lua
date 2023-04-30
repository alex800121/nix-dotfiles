vim.keymap.set("n", " ", "<Nop>", { noremap = true, buffer = false });
vim.g.mapleader = " ";
vim.keymap.set("n", "<leader>l", ":bnext<CR>", { noremap = true, buffer = false });
vim.keymap.set("n", "<leader>h", ":bprevious<CR>", { noremap = true, buffer = false });

--normal write
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, buffer = false });

--sudo write
--draft 1
vim.keymap.set("n", "<leader>W", "<cmd>silent w !sudo tee %<CR>", { noremap = true, buffer = false });
vim.api.nvim_create_autocmd({"FileChangedShell"}, { 
  pattern = { "*" },
  command = [[
    let v:fcs_choice="reload"
  ]]
})
vim.api.nvim_create_autocmd({"FileChangedShellPost"}, { 
  pattern = { "*" },
  command = [[
    echohl WarningMsg | echo "File changed. Automatic reload." | echohl None
  ]]
})

vim.keymap.set("n", "<leader>q", ":qa<CR>", { noremap = true, buffer = false });
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { noremap = true, buffer = false });
