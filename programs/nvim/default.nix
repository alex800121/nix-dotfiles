{ config, pkgs, lib, inputs, system, userConfig, ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      gruvbox-nvim
      which-key-nvim
      {
        plugin = bufferline-nvim;
        optional = false;
      }
      {
        plugin = nvim-tree-lua;
        optional = false;
      }
    ] );
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = ( with pkgs; [
      nerdfonts
    ] );
    extraLuaConfig = ''
      print("Hello")
      require'user/options'
      require'user/keymaps'
      require'user/buffer'
      require'user/nvimtree'
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
