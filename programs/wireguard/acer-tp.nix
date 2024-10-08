{ pkgs, userConfig, lib, ... }:
let
  port = 50541;
  setCred = "wg.key:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../../secrets/wg-${userConfig.hostName}));
in
{

  environment.systemPackages = with pkgs; [
    qrencode
    wireguard-tools
    nftables
  ];

  networking.firewall = {
    allowedTCPPorts = [
      53
      5353
    ];
    allowedUDPPorts = [
      53
      5353
      port
    ];
  };

  systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.services.systemd-networkd.serviceConfig.SetCredentialEncrypted = setCred;

  networking.networkmanager.unmanaged = [
    "interface-name:wg0"
  ];

  services.dnsmasq.enable = true;
  services.dnsmasq.resolveLocalQueries = true;
  services.dnsmasq.settings = {
    interface = "wg0";
  };

  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

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
          PrivateKeyFile = /run/credentials/systemd-networkd.service/wg.key;
          ListenPort = port;
          FirewallMark = 8888;
        };
        wireguardPeers = [
          {
            # pixel
            wireguardPeerConfig = {
              PublicKey = "fzF9NfUt8/0zEOdHZZMIyPVOidP5343fb+daAA3LiDg=";
              AllowedIPs = [ "10.100.0.2/32" "fcdd::2/128" ];
            };
          }
          {
            # fw13
            wireguardPeerConfig = {
              PublicKey = "1dM4ifJxT3+aWDln1RX3JmB3jJJuyMOEzob1Kt5odQ4=";
              AllowedIPs = [ "10.100.0.3/32" "fcdd::3/128" ];
            };
          }
        ];
      };
    };

    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.100.0.1/24" "fcdd::1/64" ];
      networkConfig = { IPMasquerade = "both";
        IPForward = "yes";
        MulticastDNS = true;
      };
      linkConfig = {
        Multicast = true;
        AllMulticast = true;
      };
    };
  };

  # boot.kernel.sysctl = {
  #   "net.ipv4.ip_forward" = 1;
  #   "net.ipv6.conf.all.forwarding" = 1;
  # };
}
