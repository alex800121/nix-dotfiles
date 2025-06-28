local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = {}

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.font = wezterm.font 'Hack Nerd Font Mono'
-- config.front_end = 'WebGpu'
config.window_close_confirmation = 'NeverPrompt'

local M = function (fontSize)
  config.font_size = fontSize

  return config
end

return M
