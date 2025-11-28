{ config, nixpkgsUnstable, pkgs, lib, userConfig, inputs, ... }:
{
  home.sessionVariables."CODELLDB_PATH" = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  home.sessionVariables."LIBLLDB_PATH" = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    plugins = (with pkgs.vimPlugins; [
      mini-icons
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
        haskell
      ]))
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
      nixpkgsUnstable.vimPlugins.haskell-tools-nvim
      toggleterm-nvim
      iron-nvim
      haskell-snippets-nvim
      # scrollEOF-nvim
    ]);
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      tree-sitter
      nerd-fonts.hack
      ripgrep
      fd
      haskell-language-server
      haskellPackages.hoogle
      haskellPackages.ghci-dap
      haskellPackages.haskell-dap
      haskellPackages.haskell-debug-adapter
      haskellPackages.fast-tags
      ormolu
      # nil
      inputs.nil.packages."${pkgs.stdenv.hostPlatform.system}".default
      lua-language-server
      nixpkgs-fmt
      vscode-extensions.vadimcn.vscode-lldb
    ];
  };
  xdg.configFile.nvim = {
    source = ./luaConfig;
  };
}
