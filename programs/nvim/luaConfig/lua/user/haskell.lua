-- local haskell_tools = require 'haskell-tools'
local whichkey = require 'which-key'
local luasnip = require 'luasnip'
local haskell_snippets = require('haskell-snippets').all
luasnip.add_snippets('haskell', haskell_snippets, { key = 'haskell' })

local opts = function(def) return { noremap = true, silent = true, desc = def } end

vim.g.haskell_tools = {
  tools = { -- haskell-tools options
    log = {
      level = vim.log.levels.DEBUG,
    },
    hoogle = { mode = 'auto' },
  },
  hls = {
    default_settings = {
      haskell = {
        -- The formatting providers.
        formattingProvider = 'ormolu'
      }
    },
    on_attach = function(client, bufnr, ht)
      local bufopts = function(def) return { noremap = true, silent = true, buffer = bufnr, desc = 'LSP: ' .. def } end
      -- Mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      whichkey.add({
        { '<leader>w', group = "+Workspace Folder..." },
        { '<leader>s', group = "+Set ... List" },
        { '<leader>r', group = "+GHC REPL ..." },
      })
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts('declaration'))
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts('definition'))
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts('implementation'))
      vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts('signature_help'))
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts('type definition'))
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts('references'))
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts('Next diagnostic'))
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts('Previous diagnostic'))
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts('hover'))
      vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float, opts('Open float'))
      vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts('add workspace folder'))
      vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts('remove workspace folder'))
      vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, bufopts('list workspace folder'))
      vim.keymap.set('n', '<leader>R', vim.lsp.buf.rename, bufopts('rename'))
      vim.keymap.set('n', '<leader>C', vim.lsp.buf.code_action, bufopts('code action'))
      vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, bufopts('code format'))
      vim.keymap.set('n', '<leader>sl', vim.diagnostic.setloclist, opts('Set Location List'))
      vim.keymap.set('n', '<leader>sf', vim.diagnostic.setqflist, opts('Set Quickfix List'))
      -- so auto-refresh (see advanced configuration) is enabled by default
      vim.keymap.set('n', '<leader>l', vim.lsp.codelens.run, bufopts('code lens'))
      -- Hoogle search for the type signature of the definition under the cursor
      vim.keymap.set('n', '<leader>h', ht.hoogle.hoogle_signature, bufopts('hoogle search'))
      -- Evaluate all code snippets
      vim.keymap.set('n', '<leader>E', ht.lsp.buf_eval_all, bufopts('evaluate snippets'))
      -- Toggle a GHCi repl for the current package
      vim.keymap.set('n', '<leader>rp', ht.repl.toggle, bufopts('repl for package'))
      -- Toggle a GHCi repl for the current buffer
      vim.keymap.set('n', '<leader>rb', function()
        ht.repl.toggle(vim.api.nvim_buf_get_name(0))
      end, bufopts('repl for buffer'))
      vim.keymap.set('n', '<leader>rq', ht.repl.quit, bufopts('quit repl'))
    end
  }
}
