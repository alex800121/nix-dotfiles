local config_status_ok, lsp_config = pcall(require, "lspconfig")
if not config_status_ok then
  return
end

local opts = {
  on_attach = require("user.lsp.handlers").on_attach,
  capabilities = require("user.lsp.handlers").capabilities,
}

lsp_config["hls"].setup(vim.tbl_deep_extend("force", require("user.lsp.settings.hls"), opts))
lsp_config["rnix"].setup(opts)
