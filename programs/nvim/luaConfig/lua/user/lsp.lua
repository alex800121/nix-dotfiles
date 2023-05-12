local lspconfig = require'lspconfig'
local cmp = require'cmp'

cmp.setup({
})

lspconfig['hls'].setup({
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  root_dir = function (filepath)
    return (
      lspconfig.util.root_pattern('hie.yaml', 'stack.yaml', 'cabal.project')(filepath)
      or lspconfig.util.root_pattern('*.cabal', 'package.yaml')(filepath)
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

lspconfig['nil_ls'].setup({
  cmd = { "nil" },
  filetype = { "nix" },
  root_dir = lspconfig.util.root_pattern("flake.nix", ".git"),
  single_file_support = true
})

lspconfig['lua_ls'].setup({
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = lspconfig.util.root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git"),
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      }
    }
  }
})
