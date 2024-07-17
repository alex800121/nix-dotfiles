{ pkgs, config, userConfig, ... }:
let
  port = 50541;
  hostName = userConfig.hostName;
in
{
  age.secrets."wg-${hostName}" = {
    file = ../../secrets/wg-${hostName}.age;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "600";
  };
  environment.systemPackages = with pkgs; [
    qrencode
    wireguard-tools
    nftables
  ];
  services.avahi = {
    allowPointToPoint = true;
    reflector = true;
    allowInterfaces = [
      "wg0"
      "lo"
      "enp0s13f0u1u3"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      53
    ];
    allowedUDPPorts = [
      53
      port
    ];
  };
  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1500";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets."wg-${hostName}".path;
          ListenPort = port;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "upKxh1DAailH/sUJTfa0QDj6ZLoqNJx8z4qFEHPXmCI=";
              AllowedIPs = [ "10.100.0.2/32" "fcdd::2/128" ];
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "FtEhq103TNi0evV2VWQuZ3n6/62rXZuZI9zpaysboX0=";
              AllowedIPs = [ "10.100.0.3/32" "fcdd::3/128" ];
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "kpsQ33+DHOSVggtxSnTm98jtsZxpiM0VWKmzoktTtGE=";
              AllowedIPs = [ "10.100.0.4/32" "fcdd::4/128" ];
            };
          }
        ];
      };
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.100.0.1/24" "fcdd::1/64" ];
      networkConfig = {
        IPMasquerade = "both";
        IPForward = "yes";
        MulticastDNS = "resolve";
      };
      linkConfig = {
        Multicast = true;
      };
    };
  };
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
}