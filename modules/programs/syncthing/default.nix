{ self, inputs, ... }:
{
  flake.nixosModules.syncthing =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      peers = [
        "fw13"
        "fw12"
        "alexrpi4tp"
        "oracle"
        "oracle4"
        "pixel7a"
      ];
      inherit (config.networking) hostName;
      devices = lib.genAttrs peers (x: {
        id = lib.strings.trim (builtins.readFile ../../../secrets/syncthing/id-${x});
        autoAcceptFolders = true;
      });
      user = config.initConfig.defaultUser;
    in
    {
      imports = [
        inputs.agenix.nixosModules.default
      ];
      config = {
        age.secrets.guiPasswordFile = {
          file = ../../../secrets/syncthing/pw.age;
          owner = user;
          group = "users";
        };
        age.secrets.key = {
          file = ../../../secrets/syncthing/key-${hostName}.age;
          owner = user;
          group = "users";
        };
        age.secrets.cert = {
          file = ../../../secrets/syncthing/cert-${hostName}.age;
          owner = user;
          group = "users";
        };

        services.syncthing = {
          inherit user;
          group = "users";
          enable = true;
          openDefaultPorts = true;
          key = config.age.secrets.key.path;
          cert = config.age.secrets.cert.path;
          guiPasswordFile = config.age.secrets.guiPasswordFile.path;
          overrideDevices = false;
          overrideFolders = false;
          systemService = true;
          settings.gui = {
            user = config.initConfig.defaultUser;
          };
          dataDir = "/home/${user}";
          settings = {
            inherit devices;
            folders = {
              "KeePassXC" = {
                path = "~/Sync/KeePassXC";
                devices = peers;
                versioning = {
                  type = "simple";
                  cleanupIntervalS = 604800;
                  params = {
                    keep = "30";
                    cleanoutDays = "90";
                  };
                };
                maxConflicts = -1;
                ignorePerms = true;
              };
            };
          };
        };
      };
    };
}
