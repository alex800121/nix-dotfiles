{ config, pkgs, lib, userConfig, inputs, system, ... }:
let
  nixpkgsUnstable = import inputs.nixpkgsUnstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  home.sessionVariables."CODELLDB_PATH" = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  home.sessionVariables."LIBLLDB_PATH" = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
  programs.neovim = {
    enable = true;
    plugins = (with pkgs.vimPlugins; [
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
        tree-sitter-json
      ]))
      nvim-treesitter-parsers.kdl
      nvim-treesitter-parsers.jsonc
      nvim-treesitter-textobjects
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      undotree
      lualine-nvim
      vim-fugitive
      comment-nvim
      luasnip
      friendly-snippets
      lsp_signature-nvim
      nvim-lspconfig
      nvim-autopairs
      nvim-cmp
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-treesitter
      cmp-path
      cmp-buffer
      cmp-cmdline
      lspkind-nvim
      cmp-nvim-lsp-signature-help
      nvim-dap
      nvim-dap-ui
      transparent-nvim
      nixpkgsUnstable.vimPlugins.haskell-tools-nvim
      nixpkgsUnstable.vimPlugins.toggleterm-nvim
      nixpkgsUnstable.vimPlugins.iron-nvim
      pkgs.haskell-snippets-nvim
      # scrollEOF-nvim
    ]);
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = (with pkgs; [
      tree-sitter
      nerdfonts
      ripgrep
      fd
      (nixpkgsUnstable.haskell-language-server.override { supportedGhcVersions = [ "963" ]; })
      # nixpkgsUnstable.haskell-language-server
      nixpkgsUnstable.haskellPackages.hoogle
      nixpkgsUnstable.haskellPackages.ghci-dap
      nixpkgsUnstable.haskellPackages.haskell-dap
      nixpkgsUnstable.haskellPackages.haskell-debug-adapter
      nixpkgsUnstable.haskellPackages.fast-tags
      nixpkgsUnstable.ormolu
      nil
      lua-language-server
      nixpkgs-fmt
      vscode-extensions.vadimcn.vscode-lldb
    ]);
  };
  xdg.configFile.nvim = {
    source = ./luaConfig;
  };
}
