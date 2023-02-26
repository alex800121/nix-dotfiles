if vim.fn.has('wsl') and vim.fn.executable('win32yank.exe') then
  local path = vim.fn.exepath('win32yank.exe')
  local win32yank = (function()
    if path == nil or path == '' then
      return 'win32yank.exe'
    else
      return path
    end
  end)()
  vim.g.clipboard = {
    name = "custom win32yank",
    copy = {
      ["+"] = win32yank .. " -i --crlf", --"win32yank.exe -i --crlf",
      ["*"] = win32yank .. " -i --crlf",
    },
    paste = {
      ["+"] = win32yank .. " -o --lf",
      ["*"] = win32yank .. " -o --lf",
    },
    cache_enabled = 0
  }
end
