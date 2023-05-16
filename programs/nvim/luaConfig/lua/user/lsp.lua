local lspconfig = require'lspconfig'
local cmp = require'cmp'
local luasnip = require'luasnip'
local lspkind = require'lspkind'

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Global setup.
cmp.setup({
  snippet = {
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({select = false}),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  }
})

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

local opts = function(def) return { noremap=true, silent=true, desc=def } end
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts('Next diagnostic'))
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts('Previous diagnostic'))
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts('Open float'))

local on_attach = function(client, bufnr)
  local bufopts = function(def) return { noremap=true, silent=true, buffer=bufnr, desc='LSP: ' .. def } end
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts('declaration'))
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts('definition'))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts('hover'))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts('implementation'))
  vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts('signature_help'))
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts('add workspace folder'))
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts('remove workspace folder'))
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts('list workspace folder'))
  vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition, bufopts('type definition'))
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts('rename'))
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts('code action'))
  vim.keymap.set('x', '<space>ca', vim.lsp.buf.range_code_action, bufopts('code action (range)'))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts('references'))
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts('code format'))
end

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
  single_file_support = true,
  capabilities = capabilities,
  on_attach = on_attach
})

lspconfig['nil_ls'].setup({
  cmd = { "nil" },
  filetype = { "nix" },
  root_dir = lspconfig.util.root_pattern("flake.nix", ".git"),
  single_file_support = true,
  capabilities = capabilities,
  on_attach = on_attach
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
  },
  capabilities = capabilities,
  on_attach = on_attach
})
