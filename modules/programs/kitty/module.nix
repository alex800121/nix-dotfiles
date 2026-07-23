{ inputs, ... }:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  flake.wrappers.kitty-module =
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
          description = "config dir containing kitty.conf";
        };
      };

      config = lib.mkMerge [
        {
          package = lib.mkDefault pkgs.kitty;
        }
        (lib.mkIf (config.configDir != null) {
          flags."--config" = "${config.configDir}/kitty.conf";
        })
      ];

    };
}
