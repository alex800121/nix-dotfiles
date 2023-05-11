local treesitter = require'nvim-treesitter.configs'

treesitter.setup {
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true
  },
  indent = {
    enable = true
  }
}
