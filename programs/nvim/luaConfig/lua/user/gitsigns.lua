local gitsigns = require'gitsigns'

gitsigns.setup({
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  yadm = {
    enable = false
  },
  on_attach = function(bufnr)
    local function map(mode, l, r, desc, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = 'Gitsigns: ' .. desc
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    -- Actions
    map('n', '[h', gitsigns.prev_hunk, 'Hunk: Previous')
    map('n', ']h', gitsigns.next_hunk, 'Hunk: Next')
    map('n', '<leader>hs', gitsigns.stage_hunk, 'Hunk: Stage')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Hunk: Reset')
    map('v', '<leader>hs', function() gitsigns.stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, 'Hunk: Stage')
    map('v', '<leader>hr', function() gitsigns.reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, 'Hunk: Stage')
    map('n', '<leader>Hs', gitsigns.stage_buffer, 'Buffer: Stage')
    map('n', '<leader>hu', gitsigns.undo_stage_hunk, 'Hunk: Undo Stage')
    map('n', '<leader>Hr', gitsigns.reset_buffer, 'Buffer: Reset')
    map('n', '<leader>hp', gitsigns.preview_hunk, 'Hunk: Preview')
    map('n', '<leader>bl', function() gitsigns.blame_line{full=true} end, 'Blame: This Line')
    map('n', '<leader>bt', gitsigns.toggle_current_line_blame, 'Blame: Toggle')
    map('n', '<leader>dd', gitsigns.diffthis, 'Vimdiff')
    map('n', '<leader>dD', function() gitsigns.diffthis('~') end, 'Vimdiff?')
    map('n', '<leader>td', gitsigns.toggle_deleted, 'Toggle Deleted')

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Hunk: Select')
  end
})
