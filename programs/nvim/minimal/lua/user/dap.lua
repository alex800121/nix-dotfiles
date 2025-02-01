local dap, dapui = require("dap"), require("dapui")

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  host = "127.0.0.1",
  executable = {
    -- CHANGE THIS to your path!
    command = os.getenv("CODELLDB_PATH"),
    args = { "--liblldb", os.getenv("LIBLLDB_PATH"), "--port", "${port}" },

    -- On windows you may have to uncomment this:
    -- detached = false,
  }
}

dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end



local whichkey = require 'which-key'
whichkey.add({
  { "<leader>d", group = '+Dap...' },
})

local widgets = require 'dap.ui.widgets'
local opts = function(desc) return { noremap = true, buffer = false, desc = desc or '' } end
vim.keymap.set('n', '<Leader>c', dap.continue, opts('Dap: Continue'))
vim.keymap.set('n', '<Leader>dv', dap.step_over, opts('Dap: Step Over'))
vim.keymap.set('n', '<Leader>di', dap.step_into, opts('Dap: Step Into'))
vim.keymap.set('n', '<Leader>do', dap.step_out, opts('Dap: Step Out'))
vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, opts('Dap: Toggle Breakpoint'))
vim.keymap.set('n', '<Leader>B', dap.set_breakpoint, opts('Dap: Set Breakpoint'))
vim.keymap.set('n', '<Leader>L', dap.set_breakpoint, opts('Dap: Run Last'))
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', widgets.hover, opts('Dap: Hover'))
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', widgets.preview, opts('Dap: Preview'))
vim.keymap.set('n', '<Leader>df', function()
  widgets.centered_float(widgets.frames)
end, opts('Dap: Frames'))
vim.keymap.set('n', '<Leader>ds', function()
  widgets.centered_float(widgets.scopes)
end, opts('Dap: Scopes'))
vim.keymap.set('n', '<Leader>U', dapui.toggle, opts('Dap: Toggle UI'))
