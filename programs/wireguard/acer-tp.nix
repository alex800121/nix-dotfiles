{ pkgs, config, userConfig, lib, ... }:
let
  port = 50541;
  inherit (userConfig) hostName;
  setCred = "wg.key:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../../secrets/wg-${userConfig.hostName}));
in
{
  age.secrets."wg-${hostName}" = {
    file = ../../secrets/wg-${hostName}.age;
    owner = "root";
    group = "systemd-network";
    mode = "640";
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

  systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.services.systemd-networkd.serviceConfig.SetCredentialEncrypted = setCred;

  networking.networkmanager.unmanaged = [
    "interface-name:wg0"
  ];

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
          # PrivateKeyFile = config.age.secrets."wg-${hostName}".path;
          PrivateKeyFile = /run/credentials/systemd-networkd.service/wg.key;
          ListenPort = port;
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
              PublicKey = "TKL4K+fXJqkOFQpz5p7C62QPudAZxkGdlFMi1Xv0ngA=";
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
        MulticastDNS = "resolve";
      };
      linkConfig = {
        Multicast = true;
      };
    };
  };
}
