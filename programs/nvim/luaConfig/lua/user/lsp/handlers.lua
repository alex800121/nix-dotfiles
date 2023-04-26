local M = {}

-- TODO: backfill this to template
M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = false;
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_exec(
      [[
        augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]],
      false
    )
  end
end

local function lsp_code_lens(client, bufnr)
  if client.server_capabilities.codeLensProvider then
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.api.nvim_exec(
      [[
        augroup LspCodelensAutoGroup
          autocmd! * <buffer>
          autocmd BufEnter <buffer> lua vim.lsp.codelens.refresh()
          autocmd CursorHold <buffer> lua vim.lsp.codelens.refresh()
          autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh()
        augroup end
      ]],
      false
    )
    vim.keymap.set("n", "[e", vim.lsp.codelens.run, opts)
  end
end

local function lsp_keymaps(bufnr, ori_cwd)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local function buf_set_map(mode, keys, command)
    vim.keymap.set(mode, keys, command, opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, mode, keys, command, opts)
  end
  buf_set_map("n", "gD", vim.lsp.buf.declaration)
  buf_set_map("n", "gd", vim.lsp.buf.definition)
  buf_set_map("n", "K", vim.lsp.buf.hover)
  buf_set_map("n", "gi", vim.lsp.buf.implementation)
  buf_set_map("n", "gs", vim.lsp.buf.signature_help)
  buf_set_map("n", "<leader>rn", vim.lsp.buf.rename)
  buf_set_map("n", "gr", vim.lsp.buf.references)
  buf_set_map("n", "<leader>ca", vim.lsp.buf.code_action)
  buf_set_map("n", "<leader>d", vim.diagnostic.open_float)
  buf_set_map("n", "[d", vim.diagnostic.goto_prev)
  buf_set_map("n", "]d", vim.diagnostic.goto_next)
  buf_set_map("n", "[]", vim.diagnostic.setloclist)
  -- local function custom_p_toggle()
  --   local view = require("nvim-tree.view")
  --   local nvim_tree = require("nvim-tree")
  --   local previous_buf = vim.api.nvim_get_current_buf()
  --   local cwd_list = vim.lsp.buf.list_workspace_folders()
  --   local utils = require("nvim-tree.utils")
  --   if view.is_visible() then
  --     nvim_tree.change_dir(ori_cwd)
  --     -- nvim_tree.change_root(ori_cwd, previous_buf) view.close()
  --   else
  --     if next(cwd_list) then
  --       print("success")
  --       nvim_tree.open(cwd_list[1])
  --     else
  --       print("fail")
  --       nvim_tree.open(ori_cwd)
  --     end
  --     local bufname = vim.api.nvim_buf_get_name(previous_buf)
  --     local filepath = utils.canonical_path(vim.fn.fnamemodify(bufname, ":p"))
  --     vim.schedule(function()
  --       require("nvim-tree.actions.find-file").fn(filepath)
  --     end)
  --   end
  -- end
  -- vim.keymap.set("n", "<leader>p", custom_p_toggle, opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

M.on_attach = function(client, bufnr)
  --[[
  if client.name == "tsserver" then
    client.resolved_capabilities.document_formatting = false
  end
  --]]

  local ori_cwd = vim.fn.getcwd()
  lsp_keymaps(bufnr, ori_cwd)
  lsp_highlight_document(client)
  lsp_code_lens(client, bufnr)

end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
