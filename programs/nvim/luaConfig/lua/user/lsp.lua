local lspconfig = require 'lspconfig'
local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'
require("luasnip.loaders.from_vscode").lazy_load()

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Global setup.
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
     ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i" }),
     ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i" }),
     ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
     ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
     ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
     ["<C-e>"] = cmp.mapping(cmp.mapping.close(), { "i", "c" }),
     ['<C-y>'] = cmp.mapping.confirm({ select = true }),
     ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
    { name = 'nvim_lua' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = lspkind.cmp_format({
      mode = 'symbol_text',       -- show only symbol annotations
      maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  },
  experimental = {
    ghost_text = false,
  },
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

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

local opts = function(def) return { noremap = true, silent = true, desc = def } end

local on_attach = function(client, bufnr)
  local bufopts = function(def) return { noremap = true, silent = true, buffer = bufnr, desc = 'LSP: ' .. def } end
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
  vim.keymap.set('n', 'grf', vim.lsp.buf.references, bufopts('references'))
  vim.keymap.set('n', '<space>F', function() vim.lsp.buf.format { async = true } end, bufopts('code format'))
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts('Next diagnostic'))
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts('Previous diagnostic'))
  vim.keymap.set('n', '<space>of', vim.diagnostic.open_float, opts('Open float'))
  vim.keymap.set('n', '<space>sl', vim.diagnostic.setloclist, opts('Set Location List'))
  vim.keymap.set('n', '<space>sf', vim.diagnostic.setqflist, opts('Set Quickfix List'))
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local localopts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, localopts)
    end
  })
end

lspconfig['hls'].setup({
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  root_dir = function(filepath)
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
  root_dir = lspconfig.util.root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml",
    "selene.toml", "selene.yml", ".git"),
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
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

lspconfig['rust_analyzer'].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
