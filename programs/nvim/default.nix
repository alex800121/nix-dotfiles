{ config, pkgs, lib, inputs, system, userConfig, ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      gruvbox-nvim
      which-key-nvim
      bufdelete-nvim
      bufferline-nvim
      project-nvim
      gitsigns-nvim
      nvim-tree-lua
      nvim-web-devicons
      onedark-nvim
      indent-blankline-nvim
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
      friendly-snippets
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
      vim.loader.enable()
      require'nvim-web-devicons'.setup()
      require'user.options'
      require'user.keymaps'
      require'user.indent'
      require'user.buffer'
      require'user.project'
      require'user.nvimtree'.setup()
      require'user.treesitter'
      require'user.telescope'
      require'user.undotree'
      require'user.lualine'
      require'user.comment'
      require'user.lsp'
      require'user.gitsigns'
    '';
  };
  # xdg.configFile = {
  #   nvim = {
  #     recursive = true;
  #     source = ./luaConfig;
  #   };
  # };
}
