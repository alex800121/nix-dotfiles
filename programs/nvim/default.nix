{ config, pkgs, lib, inputs, system, userConfig, ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      gruvbox-nvim
      which-key-nvim
    ] );
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = ( with pkgs; [
    ] );
    extraLuaConfig = ''
      print("Hello")
      require("user/options")
      require("user/keymaps")
    '';
  };
  xdg.configFile = {
    nvim = {
      recursive = true;
      source = ./luaConfig;
    };
  };
}
