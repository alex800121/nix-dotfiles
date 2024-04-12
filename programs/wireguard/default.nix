{ pkgs, config, ... }: let
  port = 50541;
in {
  age.secrets.wgkey = {
    file = ../../secrets/wgkey.age;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "600";
  };
  environment.systemPackages = [ pkgs.qrencode pkgs.wireguard-tools ];
  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wgkey.path;
          ListenPort = port;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "upKxh1DAailH/sUJTfa0QDj6ZLoqNJx8z4qFEHPXmCI=";
              AllowedIPs = ["10.100.0.2/32"];
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "FtEhq103TNi0evV2VWQuZ3n6/62rXZuZI9zpaysboX0=";
              AllowedIPs = ["10.100.0.3/32"];
            };
          }
        ];
      };
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = ["10.100.0.1/24"];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPForward = true;
      };
    };
  };
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
}
