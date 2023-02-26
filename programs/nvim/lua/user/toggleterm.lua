local status_ok, toggleterm = pcall(require, 'toggleterm') if not status_ok then
  return
end

toggleterm.setup({
	size = function(term)
    if term.direction == 'horizontal' then
      return vim.o.lines * 0.3
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.3
    else
      return 20
    end
  end,
  open_mapping = [[<C-t>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	-- direction = "horizontal",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  -- vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<M-H>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<M-J>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<M-K>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<M-L>', [[<C-\><C-n><C-W>l]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', '<C-M-H>', [[<C-\><C-n><C-W>h]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', '<C-M-J>', [[<C-\><C-n><C-W>j]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', '<C-M-K>', [[<C-\><C-n><C-W>k]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', '<C-M-L>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

vim.api.nvim_buf_set_keymap(0, '', '<C-t>l', ':ToggleTerm direction="vertical"<CR>', {noremap = true})
vim.api.nvim_buf_set_keymap(0, '', '<C-t>h', ':ToggleTerm direction="vertical"<CR>', {noremap = true})
vim.api.nvim_buf_set_keymap(0, '', '<C-t>j', ':ToggleTerm direction="horizontal"<CR>', {noremap = true})
vim.api.nvim_buf_set_keymap(0, '', '<C-t>k', ':ToggleTerm direction="horizontal"<CR>', {noremap = true})
vim.api.nvim_buf_set_keymap(0, '', '<C-t>t', ':ToggleTerm<CR>', {noremap = true})
