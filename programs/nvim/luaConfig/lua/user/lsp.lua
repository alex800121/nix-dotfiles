local lspconfig = require'lspconfig'
local cmp = require'cmp'

cmp.setup({
})

lspconfig['hls'].setup({
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  root_dir = function (filepath)
    return (
      util.root_pattern('hie.yaml', 'stack.yaml', 'cabal.project')(filepath)
      or util.root_pattern('*.cabal', 'package.yaml')(filepath)
    )
  end,
  settings = {
    haskell = {
      cabalFormattingProvider = "cabalfmt",
      formattingProvider = "ormolu"
    }
  },
  single_file_support = true;
})
