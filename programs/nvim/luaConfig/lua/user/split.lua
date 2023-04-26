local status_ok, split = pcall(require,'smart-splits')
if not status_ok then
  vim.notify('smart-splits not loaded')
  return
end

local opts = { noremap = true }

-- resizing splits
-- amount defaults to 3 if not specified
-- use absolute values, no + or -
local function sizeup()
  split.resize_up(1)
end
local function sizedown()
  split.resize_down(1)
end
local function sizeleft()
  split.resize_left(2)
end
local function sizeright()
  split.resize_right(2)
end

-- moving between splits
-- pass same_row as a boolean to override the default
-- for the move_cursor_same_row config option.
-- See Configuration.
-- split.move_cursor_up()
-- split.move_cursor_down()
-- split.move_cursor_left(same_row)
-- split.move_cursor_right(same_row)

-- persistent resize mode
-- temporarily remap 'h', 'j', 'k', and 'l' to
-- smart resize left, down, up, and right, respectively,
-- press <ESC> to stop resize mode (unless you've set a different key in config)
-- Start persistent resize mode
vim.keymap.set('n', '<C-w><C-w>', split.start_resize_mode, opts)


-- recommended mappings
-- resizing splits
vim.keymap.set('n', '<C-M-H>', sizeleft, opts)
vim.keymap.set('n', '<C-M-J>', sizedown, opts)
vim.keymap.set('n', '<C-M-K>', sizeup, opts)
vim.keymap.set('n', '<C-M-L>', sizeright, opts)

-- moving between splits
vim.keymap.set('n', '<M-H>', split.move_cursor_left, opts)
vim.keymap.set('n', '<M-J>', split.move_cursor_down, opts)
vim.keymap.set('n', '<M-K>', split.move_cursor_up, opts)
vim.keymap.set('n', '<M-L>', split.move_cursor_right, opts)
