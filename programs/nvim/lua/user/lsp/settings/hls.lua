-- require('lspconfig').hls.setup({})

return {
  settings = {
    haskell = {
      hintOn = true,
      formattingProvider = "ormolu",
      plugin = {
        eval = {
          globalOn = true
        }
      }
    }
  }
}
