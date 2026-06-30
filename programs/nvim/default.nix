{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  # home.sessionVariables."CODELLDB_PATH" = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  # home.sessionVariables."LIBLLDB_PATH" = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    plugins = (
      with pkgs.vimPlugins;
      [
        mini-icons
        gruvbox-nvim
        which-key-nvim
        (nvim-treesitter.withPlugins (
          p: with p; [
            haskell
            nix
          ]
        ))
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-nvim
      ]
    );
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    # extraLuaPackages = lp: with lp; [ jsregexp ];
    extraPackages = with pkgs; [
      tree-sitter
      nerd-fonts.hack
      ripgrep
      fd
      haskell.packages.ghc912.cabal-gild
      haskell.packages.ghc912.fast-tags
      haskell.packages.ghc912.haskell-language-server
      fourmolu
      inputs.nil.packages."${system}".default
      nixfmt
      lua-language-server
      vscode-extensions.vadimcn.vscode-lldb
    ];
  };
  xdg.configFile."fourmolu.yaml" = {
    source = ./fourmolu.yaml;
  };
  xdg.configFile.nvim = {
    source = ./luaConfig;
  };
}
