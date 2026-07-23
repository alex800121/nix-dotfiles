{ inputs, ... }:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];
  flake.wrappers.neovim-min-module =
    {
      config,
      wlib,
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
          nil
          nixfmt
          lua-language-server
        ];

        settings.config_directory = ./minimal;
      };
    };
}
