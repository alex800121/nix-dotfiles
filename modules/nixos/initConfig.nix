{
  lib,
  config,
  ...
}:
{
  flake.nixosModules.initConfig = {
    options.initConfig = {
      defaultUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "default user name";
      };
      hostName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "host name";
      };
      topo = lib.mkOption {
        description = "may use topo if hosts are related";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              id = lib.mkOption { type = lib.types.ints.u8; };
              peers = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              keepalived.router.id = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.u8;
                default = null;
              };
              keepalived.router.priority = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.u8;
                default = null;
              };
            };
          }
        );
        default = { };
      };
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.u8;
        default = config.initConfig.topo."${config.networking.hostName}".id or null;
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
  };
}
