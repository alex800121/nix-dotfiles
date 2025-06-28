{ userConfig, ... }: {
  programs.wezterm = {
    enable = true;
    enableBashIntegration = false;
    # enableBashIntegration = true;
    extraConfig = ''
      local default = require 'user.default'
      return default(${builtins.toString userConfig.fontSize})
    '';
  };
  xdg.configFile."wezterm/user" = {
    enable = true;
    source = ./config;
    recursive = true;
  };
}
