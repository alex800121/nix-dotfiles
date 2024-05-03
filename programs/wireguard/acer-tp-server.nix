{ pkgs, config, ... }:
let
  port = 50541;
in
{
  age.secrets.wgkey = {
    file = ../../secrets/wgkey.age;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "600";
  };
  environment.systemPackages = with pkgs; [
    qrencode
    wireguard-tools
    nftables
  ];
  # networking.nat = {
  #   enable = true;
  #   enableIPv6 = true;
  #   externalInterface = "enp0s13f0u1u3";
  #   internalInterfaces = [ "wg0" ];
  #   externalIP = null;
  # };
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
          PrivateKeyFile = config.age.secrets.wgkey.path;
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
        ];
      };
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.100.0.1/24" "fcdd::1/64" ];
      networkConfig = {
        IPMasquerade = "both";
        IPForward = "yes";
        # MulticastDNS = "resolve";
      };
    };
  };
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  # networking.firewall.extraCommands = ''
  #   iptables -A FORWARD -i wg0 -j ACCEPT
  #   iptables -t nat -A POSTROUTING -s 10.100.0.1/24 -o enp0s13f0u1u3  -j MASQUERADE
  #   ip6tables -A FORWARD -i wg0 -j ACCEPT
  #   ip6tables -t nat -A POSTROUTING -s fcdd::1/64 -o enp0s13f0u1u3 -j MASQUERADE
  # '';
  # networking.firewall.extraStopCommands = ''
  #   iptables -D FORWARD -i wg0 -j ACCEPT
  #   iptables -t nat -D POSTROUTING -s 10.100.0.1/24 -o enp0s13f0u1u3 -j MASQUERADE
  #   ip6tables -D FORWARD -i wg0 -j ACCEPT
  #   ip6tables -t nat -D POSTROUTING -s fcdd::1/64 -o enp0s13f0u1u3 -j MASQUERADE
  # '';
}
