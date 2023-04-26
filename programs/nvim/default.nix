{ config, pkgs, lib, inputs, system, userConfig, imports ? [], ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
    ] );
    extraPackages = ( with pkgs; [
    ] );
    extraLuaConfig = ''
      print("Hello")
    '';
  };
  xdg.configFile = {
    nvim = {
      recursive = true;
      source = ./luaConfig;
    };
  };
}
