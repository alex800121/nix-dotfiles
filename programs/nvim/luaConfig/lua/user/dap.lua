local dap, dapui = require("dap"), require("dapui")

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  host = "127.0.0.1",
  executable = {
    -- CHANGE THIS to your path!
    command = os.getenv("CODELLDB_PATH"),
    args = {"--liblldb", os.getenv("LIBLLDB_PATH"), "--port", "${port}"},

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

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
