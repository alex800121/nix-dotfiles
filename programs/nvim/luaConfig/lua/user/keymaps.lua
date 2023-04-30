vim.keymap.set("n", " ", "<Nop>", { noremap = true, buffer = false });
vim.g.mapleader = " ";
vim.keymap.set("n", "<leader>l", ":bnext<CR>", { noremap = true, buffer = false });
vim.keymap.set("n", "<leader>h", ":bprevious<CR>", { noremap = true, buffer = false });

--normal write
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, buffer = false });

--sudo write
--draft 2.5
vim.keymap.set("n", "<leader>W", function()
  vim.api.nvim_exec2([[
    silent write !sudo tee %
    echohl WarningMsg | echomsg "Sudo write." | echohl None
  ]], {})
end, { noremap = true, buffer = false, silent = true });
vim.api.nvim_create_autocmd({"FileChangedShell"}, { 
  pattern = { "*" },
  command = [[
    let v:fcs_choice="edit"
  ]]
})

vim.keymap.set("n", "<leader>q", ":qa<CR>", { noremap = true, buffer = false });
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { noremap = true, buffer = false });
