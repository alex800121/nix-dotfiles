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
  };
}
