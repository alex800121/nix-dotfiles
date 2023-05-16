{ config, pkgs, lib, inputs, system, userConfig, ... }: let
  nixpkgsStable = import inputs.nixpkgsStable { inherit system; config.allowUnfree = true; };
in {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      gruvbox-nvim
      which-key-nvim
      bufferline-nvim
      nvim-tree-lua
      nvim-web-devicons
      onedark-nvim
      (nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-lua 
        tree-sitter-haskell 
        tree-sitter-rust 
        tree-sitter-c 
        tree-sitter-vim 
        tree-sitter-nix 
      ]))
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      undotree
      lualine-nvim
      vim-fugitive
      comment-nvim
      luasnip
      nvim-lspconfig
      nvim-cmp
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-treesitter
      cmp-path
      cmp-buffer
      cmp-cmdline
      lspkind-nvim
    ] );
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = ( with pkgs; [
      nerdfonts
      ripgrep
      fd
      (haskell-language-server.override { supportedGhcVersions = [ "927" "944" ]; })
      nil
      lua-language-server
    ] );
    extraLuaConfig = ''
      print("Hello")
      require'nvim-web-devicons'.setup()
      require'user.options'
      require'user.keymaps'
      require'user.buffer'
      require'user.nvimtree'.setup()
      require'user.treesitter'
      require'user.telescope'
      require'user.undotree'
      require'user.lualine'
      require'user.comment'
      require'user.lsp'
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
