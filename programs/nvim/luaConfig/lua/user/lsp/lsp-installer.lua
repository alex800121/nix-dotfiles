local installer_status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not installer_status_ok then
	return
end

local config_status_ok, lsp_config = pcall(require, "lspconfig")
if not config_status_ok then
  return
end

local opts = {
  on_attach = require("user.lsp.handlers").on_attach,
  capabilities = require("user.lsp.handlers").capabilities,
}
-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(
  function(server)

    if server.name == "sumneko_lua" then
      local sumneko_opts = require("user.lsp.settings.sumneko_lua")
      opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
    end

    if server.name == "rust-analyzer" then
      local rust_opts = require("user.lsp.settings.rust-analyzer")
      opts = vim.tbl_deep_extend("force", rust_opts, opts)
    end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
  end
)

lsp_config["hls"].setup(vim.tbl_deep_extend("force", require("user.lsp.settings.hls"), opts))
lsp_config["rnix"].setup(opts)
