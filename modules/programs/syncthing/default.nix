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
              "Documents" = {
                path = "~/Documents";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Calibre Library" = {
                path = "~/Calibre Library";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Zotero" = {
                path = "~/Zotero";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Videos" = {
                path = "~/Videos";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Templates" = {
                path = "~/Templates";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Projects" = {
                path = "~/Projects";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Pictures" = {
                path = "~/Pictures";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Music" = {
                path = "~/Music";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
              "Desktop" = {
                path = "~/Desktop";
                # type =
                #   if hostName == "fw12" then
                #     "receiveonly"
                #   else if hostName == "fw13" then
                #     "sendonly"
                #   else
                #     "sendreceive";
                devices = [
                  "fw13"
                  "fw12"
                ];
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
