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
    in
    {
      imports = [
        inputs.agenix.nixosModules.default
      ];
      config = {
        age.secrets.guiPasswordFile = {
          file = ../../../secrets/syncthing/pw.age;
        };
        age.secrets.key = {
          file = ../../../secrets/syncthing/key-${hostName}.age;
        };
        age.secrets.cert = {
          file = ../../../secrets/syncthing/cert-${hostName}.age;
        };

        systemd.targets.multi-user.wants = [
          "syncthing@${config.initConfig.defaultUser}.service"
        ];

        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
          key = config.age.secrets.key.path;
          cert = config.age.secrets.cert.path;
          guiPasswordFile = config.age.secrets.guiPasswordFile.path;
          overrideDevices = false;
          overrideFolders = false;
          systemService = false;
          dataDir = "/home/${config.initConfig.defaultUser}";
          settings.gui = {
            user = config.initConfig.defaultUser;
          };
          settings = {
            inherit devices;
            folders = {
              "KeePassXC" = {
                path = "~/Sync/KeePassXC";
                devices = peers;
                versioning = {
                  type = "simple";
                  params.keep = "20";
                };
                maxConflicts = -1;
              };
            };
          };
        };
      };
    };
}
