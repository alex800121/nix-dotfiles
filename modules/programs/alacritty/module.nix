{ inputs, ... }:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  flake.wrappers.alacritty-module =
    {
      config,
      wlib,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        wlib.modules.default
      ];

      options = {
        configDir = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "config dir containing alacritty.toml";
        };
      };

      config = lib.mkMerge [
        {
          package = lib.mkDefault pkgs.alacritty;
        }
        (lib.mkIf (config.configDir != null) {
          flags."--config-file" = "${config.configDir}/alacritty.toml";
        })
      ];

    };
}
