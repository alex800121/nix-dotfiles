local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  print("lspconfig not found")
	return
end

--require("lsp.settings.hls")
-- require("user.lsp.lsp-installer")
require("user.lsp.lsp-config")
require("user.lsp.handlers").setup()

--require('lspconfig').hls.setup({})
