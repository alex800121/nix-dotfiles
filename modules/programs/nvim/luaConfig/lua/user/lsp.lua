local whichkey = require 'which-key'

vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'popup' }
vim.opt.complete = { '.', 'o', 'w', 'b', 'u', 't' }

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
  },
})
local opts = function(def) return { noremap = true, silent = true, desc = def } end

local on_attach = function(client, bufnr)
  local bufopts = function(def) return { noremap = true, silent = true, buffer = bufnr, desc = 'LSP: ' .. def } end
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  whichkey.add({
    { '<leader>w', group = "+Workspace Folder..." },
    { '<leader>s', group = "+Set ... List" },
  })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts('declaration'))
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts('definition'))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts('implementation'))
  vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts('signature_help'))
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts('type definition'))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts('references'))
  vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts('Next diagnostic'))
  vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts('Previous diagnostic'))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts('hover'))
  vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float, opts('Open float'))
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts('add workspace folder'))
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts('remove workspace folder'))
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts('list workspace folder'))
  vim.keymap.set('n', '<leader>R', vim.lsp.buf.rename, bufopts('rename'))
  vim.keymap.set('n', '<leader>C', vim.lsp.buf.code_action, bufopts('code action'))
  vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, bufopts('code lens'))
  vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, bufopts('code format'))
  vim.keymap.set('n', '<leader>sl', vim.diagnostic.setloclist, opts('Set Location List'))
  vim.keymap.set('n', '<leader>sf', vim.diagnostic.setqflist, opts('Set Quickfix List'))
  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  vim.bo.autocomplete = vim.bo.buftype == ""
end

vim.lsp.config['hls'] = {
  cmd = { 'haskell-language-server-wrapper', '--lsp' },
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  root_markers = { '*.cabal', 'stack.yaml', 'cabal.project', 'package.yaml', 'hie.yaml', '.git' },
  single_file_support = true,
  settings = {
    haskell = {
      cabalFormattingProvider = "cabal-gild",
      formattingProvider = "fourmolu",
      plugin = {
        fourmolu = {
          config = {
            external = true
          }
        }
      }
    }
  },
  on_attach = on_attach,
}
vim.lsp.enable('hls')

vim.lsp.config['nil_ls'] = {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" },
      },
      flake = {
        autoArchive = true,
        autoEvalInputs = true,
        nixpkgsInputName = "nixos"
      }
    },
  },
  on_attach = on_attach
}
vim.lsp.enable('nil_ls')

vim.lsp.config['lua_ls'] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml",
    "selene.toml", "selene.yml", ".git" },
  single_file_support = false,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      }
    }
  },
  on_attach = on_attach
}
vim.lsp.enable('lua_ls')

vim.lsp.config['rust_analyzer'] = {
  root_markers = { "*.cargo" },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        features = "all",
      },
      -- Add clippy lints for Rust.
      checkOnSave = true,
      check = {
        command = "clippy",
        features = "all",
      },
      procMacro = {
        enable = true,
      },
    },
  },
  -- capabilities = capabilities,
  on_attach = on_attach,
}
vim.lsp.enable('rust_analyzer')
