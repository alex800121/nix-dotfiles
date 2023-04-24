{ config, pkgs, lib, inputs, system, userConfig, imports ? [], ... }: {
  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      smart-splits-nvim
      dracula-vim
      tokyonight-nvim
      popup-nvim
      gruvbox-nvim
      plenary-nvim
      comment-nvim
      nvim-web-devicons
      nvim-tree-lua
      bufferline-nvim
      vim-bbye
      lualine-nvim
      toggleterm-nvim
      nvim-cmp
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      luasnip
      friendly-snippets
      nvim-lspconfig
      telescope-nvim
      playground
      nvim-ts-rainbow
      smart-splits-nvim
      ( nvim-treesitter.withPlugins (plugins: with pkgs.tree-sitter-grammars; [
        tree-sitter-c
        tree-sitter-haskell
        tree-sitter-nix
        tree-sitter-lua
        tree-sitter-rust
      ] ) )
    ] );
    extraPackages = ( with pkgs; [
      rnix-lsp
      fd
    ] );
    extraConfig = "luafile $HOME/.config/nvim/init_lua.lua";
  };
  xdg.configFile = {
    nvim = {
      recursive = true;
      source = ./.;
    };
  };
}
