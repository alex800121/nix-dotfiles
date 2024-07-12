{ config, pkgs, lib, userConfig, inputs, system, ... }:
let
  nixpkgsUnstable = import inputs.nixpkgsUnstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  home.sessionVariables."CODELLDB_PATH" = "${nixpkgsUnstable.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  home.sessionVariables."LIBLLDB_PATH" = "${nixpkgsUnstable.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
  programs.neovim = {
    enable = true;
    package = nixpkgsUnstable.neovim-unwrapped;
    plugins = (with nixpkgsUnstable.vimPlugins; [
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
      # (nvim-treesitter.withPlugins (p: with p; [
      #   c
      #   cpp
      #   lua
      #   markdown
      #   query
      #   haskell
      #   rust
      #   nix
      #   json
      #   yaml
      #   toml
      #   vim
      #   vimdoc
      # ]))
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
      # cmp-treesitter
      cmp-path
      cmp-buffer
      cmp-cmdline
      lspkind-nvim
      cmp-nvim-lsp-signature-help
      nvim-dap
      nvim-dap-ui
      transparent-nvim
      haskell-tools-nvim
      toggleterm-nvim
      iron-nvim
      haskell-snippets-nvim
      # scrollEOF-nvim
    ]);
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = (with nixpkgsUnstable; [
      nerdfonts
      ripgrep
      fd
      haskell-language-server
      haskellPackages.hoogle
      haskellPackages.ghci-dap
      haskellPackages.haskell-dap
      haskellPackages.haskell-debug-adapter
      haskellPackages.fast-tags
      ormolu
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
