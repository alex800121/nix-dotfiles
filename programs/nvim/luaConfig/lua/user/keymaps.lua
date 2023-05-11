local whichkey = require'which-key'

whichkey.setup()

--vim.keymap.set("n", " ", "<Nop>", { noremap = true, buffer = false })
vim.g.mapleader = " "
vim.keymap.set("n", "L", "<Nop>", { noremap = true, buffer = false })
vim.keymap.set("n", "H", "<Nop>", { noremap = true, buffer = false })
vim.keymap.set("n", "L", "<cmd>BufferLineCycleNext<cr>", { noremap = true, buffer = false })
vim.keymap.set("n", "H", "<cmd>BufferLineCyclePrev<cr>", { noremap = true, buffer = false })

--normal write
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { noremap = true, buffer = false })

--sudo write
vim.keymap.set("n", "<leader>W", function()
  vim.api.nvim_exec2([[
    silent write !sudo tee %
    echohl WarningMsg | echomsg "Sudo write." | echohl None
  ]], {})
end, { noremap = true, buffer = false, silent = true, desc = "Sudo write" })
vim.api.nvim_create_autocmd({"FileChangedShell"}, { 
  pattern = { "*" },
  command = [[
    let v:fcs_choice="edit"
  ]]
})

vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { noremap = true, buffer = false })
vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", { noremap = true, buffer = false })

vim.keymap.set("v", ">", ">gv", { noremap = true, buffer = false })
vim.keymap.set("v", "<", "<gv", { noremap = true, buffer = false })

