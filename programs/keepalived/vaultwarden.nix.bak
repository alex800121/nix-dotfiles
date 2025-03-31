{ config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routerIds;
  inherit (builtins) toString;
  bridgeName = "bridge${toString master}";
  pow = x: y: if y <= 0 then 1 else (x * (pow x (y - 1)));
  master = lib.head routerIds;
  peers = lib.tail routerIds;
  masterIp = "192.168.60.${toString master}";
  peersIp = lib.map (x: "192.168.60.${toString x}") peers;
  masterTsIp = "100.64.0.${toString master}";
  initPrio = 100;
  buildInstance = n: id:
    let ids = toString id; in {
      services.keepalived.vrrpInstances."VW_${ids}" = {
        priority = initPrio - n;
        state = if n == 0 then "MASTER" else "BACKUP";
        interface = bridgeName;
        virtualIps = [
          {
            addr = "192.168.101.${ids}/24";
            label = "${bridgeName}:vw${ids}";
          }
        ];
        virtualRouterId = id;
        unicastSrcIp = masterIp;
        unicastPeers = peersIp;
      };
      # services.keepalived.vrrpInstances."VW_DB_${ids}" = {
      #   priority = initPrio - n;
      #   state = if n == 0 then "MASTER" else "BACKUP";
      #   interface = "${bridgeName}";
      #   virtualIps = [
      #     {
      #       addr = "192.168.51.${ids}/24";
      #       label = "${bridgeName}:db${ids}";
      #     }
      #   ];
      #   virtualRouterId = id + 100;
      #   unicastSrcIp = masterIp;
      #   unicastPeers = peersIp;
      # };
    };
  buildVxlan = peer:
    let
      networkId = lib.foldl' (acc: x: acc + (pow 2 x)) 0 [ peer master ];
      name = "vxlan${toString networkId}";
    in
    {
      systemd.network.netdevs."20-${name}" = {
        netdevConfig = {
          Name = name;
          Kind = "vxlan";
        };
        vxlanConfig = {
          VNI = networkId;
          Remote = "100.64.0.${toString peer}";
          Local = masterTsIp;
          MacLearning = true;
          DestinationPort = 4789;
          Independent = true;
        };
      };
      systemd.network.networks."20-${name}" = {
        matchConfig = {
          Name = name;
        };
        bridge = [ bridgeName ];
      };
    };
in
lib.foldl'
  lib.recursiveUpdate
  (lib.foldl'
    lib.recursiveUpdate
  {
    services.keepalived.enable = true;
    services.keepalived.openFirewall = true;
    services.keepalived.extraGlobalDefs = ''
       # delay for second set of gratuitous ARPs after transition to MASTER
      vrrp_garp_master_delay 10    # seconds, default 5, 0 for no second set

      # number of gratuitous ARP messages to send at a time after transition to MASTER
      vrrp_garp_master_repeat 1    # default 5

      # delay for second set of gratuitous ARPs after lower priority advert received when MASTER
      vrrp_garp_lower_prio_delay 10

      # number of gratuitous ARP messages to send at a time after lower priority advert received when MASTER
      vrrp_garp_lower_prio_repeat 1

      # minimum time interval for refreshing gratuitous ARPs while MASTER
      vrrp_garp_master_refresh 60  # secs, default 0 (no refreshing)

      # number of gratuitous ARP messages to send at a time while MASTER
      vrrp_garp_master_refresh_repeat 2 # default 1

      # Delay in ms between gratuitous ARP messages sent on an interface
      vrrp_garp_interval 0.001          # decimal, seconds (resolution usecs). Default 0.

      # Delay in ms between unsolicited NA messages sent on an interface
      vrrp_gna_interval 0.000001
    '';
    systemd.network.netdevs."10-${bridgeName}" = {
      netdevConfig = {
        Name = bridgeName;
        Kind = "bridge";
      };
    };
    systemd.network.networks."10-${bridgeName}" = {
      matchConfig.Name = bridgeName;
      networkConfig = {
        Address = "${masterIp}/24";
        DHCP = "no";
        LinkLocalAddressing = false;
      };
    };
  }
    (lib.map buildVxlan peers))
  (lib.imap0 buildInstance routerIds)
