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
