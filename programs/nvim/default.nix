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
      nvim-treesitter
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      undotree
    ] );
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = ( with pkgs; [
      nerdfonts
      ripgrep
      fd
    ] );
    extraLuaConfig = ''
      print("Hello")
      require'user.options'
      require'user.keymaps'
      require'user.buffer'
      require'nvim-web-devicons'.setup()
      require'user.nvimtree'.setup()
      require'user.treesitter'
      require'user.telescope'
      require'user.undotree'
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
