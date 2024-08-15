{ nixpkgsUnstable, lib, pkgs, userConfig, ... }:
let
  port = 50541;
  setCred = "wg.key:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../../secrets/wg-${userConfig.hostName}));
in
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    nftables
    nixpkgsUnstable.impala
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
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport ${toString port} -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport ${toString port} -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport ${toString port} -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport ${toString port} -j RETURN || true
    '';
  };

  systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.services.systemd-networkd.serviceConfig.SetCredentialEncrypted = setCred;

  systemd.network.enable = true;

  systemd.network.netdevs."50-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
      MTUBytes = "1400";
    };
    wireguardConfig = {
      PrivateKeyFile = /run/credentials/systemd-networkd.service/wg.key;
      ListenPort = port;
      FirewallMark = 8888;
    };
    wireguardPeers = [
      {
        # acer-tp
        wireguardPeerConfig = {
          PublicKey = "7T0/ZgqGQTog13UTv4GywxrglggHV3jnppfCiySI+1E=";
          AllowedIPs = [ "0.0.0.0/0" "::/0" ];
          Endpoint = "alexacer-tp.duckdns.org:" + builtins.toString port;
        };
      }
    ];
  };

  systemd.network.networks."wg0" = {
    matchConfig.Name = "wg0";
    linkConfig = {
      Multicast = true;
      AllMulticast = true;
      ActivationPolicy = "up";
    };
    address = [ "10.100.0.3/24" "fcdd::3/64" ];
    dns = [
      "10.100.0.1"
      "fcdd::1"
    ];
    domains = [
      "~."
    ];
    networkConfig = {
      IPForward = "yes";
      MulticastDNS = true;
    };
    routes = [
      {
        routeConfig = {
          Destination = "::/0";
          Gateway = "fcdd::1";
          Table = 1000;
        };
      }
      {
        routeConfig = {
          Destination = "0.0.0.0/0";
          Gateway = "10.100.0.1";
          Table = 1000;
        };
      }
    ];
    routingPolicyRules = [
      {
        routingPolicyRuleConfig = {
          Family = "both";
          Table = "main";
          SuppressPrefixLength = 0;
          Priority = 5;
        };
      }
      {
        routingPolicyRuleConfig = {
          Family = "both";
          FirewallMark = 8888;
          InvertRule = true;
          Table = 1000;
          Priority = 10;
        };
      }
    ];
  };
}
