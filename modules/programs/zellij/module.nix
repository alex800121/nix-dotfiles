
{ inputs, ... }:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  flake.wrappers.zellij-module =
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
        programs.zellij.configFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "config file for zellij";
        };
      };

      config = lib.mkMerge [
        {
          package = lib.mkDefault pkgs.zellij;
        }
        (lib.mkIf (config.programs.zellij.configFile != null) {
          env.ZELLIJ_CONFIG_FILE = config.programs.zellij.configFile;
        })
      ];

    };
}
