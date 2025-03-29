{ config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routerIds;
  inherit (builtins) toString;
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
        interface = "bridge1";
        virtualIps = [
          {
            addr = "192.168.50.${ids}/24";
            label = "bridge1:vw${ids}";
          }
        ];
        virtualRouterId = id;
        unicastSrcIp = masterIp;
        unicastPeers = peersIp;
      };
      # services.keepalived.vrrpInstances."VW_DB_${ids}" = {
      #   priority = initPrio - n;
      #   state = if n == 0 then "MASTER" else "BACKUP";
      #   interface = "bridge1";
      #   virtualIps = [
      #     {
      #       addr = "192.168.51.${ids}/24";
      #       label = "bridge1:db${ids}";
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
        bridge = [ "bridge1" ];
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
    systemd.network.netdevs."10-bridge1" = {
      netdevConfig = {
        Name = "bridge1";
        Kind = "bridge";
      };
    };
    systemd.network.networks."10-bridge1" = {
      matchConfig.Name = "bridge1";
      networkConfig = {
        Address = "${masterIp}/24";
        DHCP = "no";
      };
    };
  }
    (lib.map buildVxlan peers))
  (lib.imap0 buildInstance routerIds)
