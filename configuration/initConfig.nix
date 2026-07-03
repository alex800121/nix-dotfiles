{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.initConfig = {
    defaultUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "default user name";
    };
    hostName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "host name";
    };
    id = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.u8;
      default = (import ./topo.nix)."${config.networking.hostName}".id or null;
    };
  };
  config = lib.mkMerge [

    (lib.mkIf (config.initConfig.hostName != null) {
      networking.hostName = lib.mkDefault config.initConfig.hostName;
    })

    ({
      warnings = lib.optional (
        config.initConfig.hostName == null
      ) "initConfig.hostName is not set. Use default (likely nixos)";
    })

  ];
}
