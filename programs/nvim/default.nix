{ config, pkgs, lib, inputs, system, userConfig, ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      {
        plugin = gruvbox-nvim;
	optional = false;
      }
    ] );
    extraPackages = ( with pkgs; [
    ] );
    extraLuaConfig = ''
      print("Hello")
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
