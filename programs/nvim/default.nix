{ config, pkgs, lib, inputs, system, userConfig, ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      gruvbox-nvim
      which-key-nvim
      { 
        plugin = bufferline-nvim;
        optional = false;
        type = "lua";
        config = ''
        '';
      }
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
      --require("user/buffer")
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
