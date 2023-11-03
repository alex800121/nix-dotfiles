{ pkgs, config, userConfig, ... }: let
  port = 50541;

in {
  users.groups.wireguard = {};
  users.extraUsers.wireguard = {
    name = "wireguard";
    group = "wireguard";
    isSystemUser = true;
  };
  age.secrets.wgkey = {
    file = ../../secrets/wgkey.age;
    owner = "wireguard";
    group = "wireguard";
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
              PublicKey = "xx";
              AllowedIPs = ["10.100.0.2"];
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
