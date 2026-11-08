{ inputs, ... }: {
  flake.nixosModules.amneziawg-client =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
      options = { };
      config = {
        networking.networkmanager = {
          unmanaged = [ "interface-name:awg0" ];
        };
        services.resolved.enable = true;
        networking.firewall.checkReversePath = "loose";

        age.secrets."amneziawg-private-${config.networking.hostName}.key".file =
          ../../../secrets/amneziawg-private-${config.networking.hostName}.age;
        age.secrets."amneziawg-shared.key".file = ../../../secrets/amneziawg-shared.age;

        systemd.services.wg-quick-awg0.serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };

        # AmneziaWG server
        networking.wg-quick.interfaces.awg0 = {
          type = "amneziawg";
          mtu = 1280;
          address = "10.88.0.2/32";
          dns = "1.1.1.1";
          privateKeyFile = config.age."amneziawg-private-${config.networking.hostName}.key".path;
          extraOptions = {
            Jc = 4;
            Jmin = 40;
            Jmax = 100;
            S1 = 64;
            S2 = 96;
            S3 = 16;
            S4 = 16;
            H1 = 918517201;
            H2 = 918517202;
            H3 = 918517203;
            H4 = 918517204;
            ContentPaddingAddition = 16;
          };
          configFile = config.age.secrets."amneziawg-shared.key".path;
          autostart = true;
          peers = [
            {
              publicKey = "tsSe222tLYP/S7tzCz750I+e64a3lUpb+DleXNYaElY=";
              endpoint = "168.107.66.23:51820";
              allowedIPs = [ "0.0.0.0/0" ];
              persistentKeepalive = 25;
            }
          ];
        };

      };
    };
  flake.nixosModules.amneziawg-server =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
      options = { };
      config = {
        age.secrets."amneziawg-private-${config.networking.hostName}.key".file =
          ../../../secrets/amneziawg-private-${config.networking.hostName}.age;
        age.secrets."amneziawg-shared.key".file = ../../../secrets/amneziawg-shared.age;

        # AmneziaWG server
        networking.wg-quick.interfaces.awg0 = {
          type = "amneziawg";
          mtu = 1280;
          address = "10.88.0.1/24";
          listenPort = 51820;
          privateKeyFile = config.age."amneziawg-private-${config.networking.hostName}.key".path;
          extraOptions = {
            Jc = 4;
            Jmin = 40;
            Jmax = 100;
            S1 = 64;
            S2 = 96;
            S3 = 16;
            S4 = 16;
            H1 = 918517201;
            H2 = 918517202;
            H3 = 918517203;
            H4 = 918517204;
            ContentPaddingAddition = 16;
          };
          configFile = config.age.secrets."amneziawg-shared.key".path;
          autostart = true;
          peers = [
            {
              publicKey = "FLJPiWFdT6g22HCE+0uem0r4ZCLaH0uRgKomFCKpU3w=";
              allowedIPs = [ "10.88.0.2/32" ];
            }
          ];
        };

        # Firewall
        networking.firewall = {
          enable = true;
          allowedUDPPorts = [ 51820 ];
          trustedInterfaces = [ "awg0" ];
        };

        # IPv4 forwarding + NAT
        networking.nat = {
          enable = true;
          externalInterface = "eth0";
          internalInterfaces = [ "awg0" ];
        };

      };
    };
}
