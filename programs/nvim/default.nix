{ config, pkgs, lib, inputs, system, userConfig, ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      gruvbox-nvim
      which-key-nvim
      bufferline-nvim
      nvim-tree-lua
      nvim-web-devicons
      onedark-nvim
    ] );
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = ( with pkgs; [
      nerdfonts
    ] );
    extraLuaConfig = ''
      print("Hello")
      require'user.options'
      require'user.keymaps'
      require'user.buffer'
      require'user.nvimtree'.setup()
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
