{
  wlib,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    wlib.wrapperModules.neovim
  ];

  config = {
    specs.general = {
      enable = true;
      data = with pkgs.vimPlugins; [
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
      ];
    };

    runtimePkgs = with pkgs; [
      tree-sitter
      nerd-fonts.hack
      ripgrep
      fd
      haskell.packages.ghc912.cabal-gild
      haskell.packages.ghc912.fast-tags
      haskell.packages.ghc912.haskell-language-server
      fourmolu
      # inputs.nil.packages."${system}".default
      nil
      nixfmt
      lua-language-server
      vscode-extensions.vadimcn.vscode-lldb
    ];

    settings.config_directory = ./luaConfig;
  };

}
