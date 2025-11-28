{ config, pkgs, lib, nixpkgsUnstable, userConfig, inputs, system, ... }:
{
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
      cmp-path
      cmp-buffer
      cmp-cmdline
      lspkind-nvim
      cmp-nvim-lsp-signature-help
      nvim-dap
      nvim-dap-ui
      transparent-nvim
      toggleterm-nvim
      iron-nvim
    ]);
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      tree-sitter
      ripgrep
      fd
      nil
      lua-language-server
      nixpkgs-fmt
    ];
  };
  xdg.configFile.nvim = {
    source = ./minimal;
  };
}
