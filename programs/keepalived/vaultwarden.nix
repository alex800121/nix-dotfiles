{ config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routerIds;
  master = lib.head routerIds;
  peers = lib.tail routerIds;
  masterIp = "192.168.53.${builtins.toString master}";
  peersIp = lib.map (x: "192.168.53.${builtins.toString x}") peers;
  initPrio = 100;
  buildInstance = n: id:
    let ids = builtins.toString id; in {
      services.keepalived.vrrpInstances."VW_${ids}" = {
        priority = initPrio - n;
        state = if n == 0 then "MASTER" else "BACKUP";
        interface = "vbr1";
        virtualIps = [
          {
            addr = "192.168.50.${ids}/24";
            label = "vbr1:vw${ids}";
          }
        ];
        virtualRouterId = id;
        unicastSrcIp = masterIp;
        unicastPeers = peersIp;
      };
      services.keepalived.vrrpInstances."VW_DB_${ids}" = {
        priority = initPrio - n;
        state = if n == 0 then "MASTER" else "BACKUP";
        interface = "vbr1";
        virtualIps = [
          {
            addr = "192.168.51.${ids}/24";
            label = "vbr1:db${ids}";
          }
        ];
        virtualRouterId = id + 100;
        unicastSrcIp = masterIp;
        unicastPeers = peersIp;
      };
    };
  buildVxlan = peer:
    let
      networkId = lib.foldl' (acc: x: acc + (x * 2)) 0 (lib.sort [ peer master ]);
      name = "vxlan${builtins.toString networkId}";
    in
    {
      systemd.network.netdevs."20-${name}" = { 
        netdevConfig = {
          Name = name;
          Kind = "vxlan";
        };
        vxlanConfig = {
          VNI = networkId;
          # Remote = "192.168.53.${peer}";
          # Local = "192.168.53.${master}";
          Group = "224.0.0.1";
          MacLearning = true;
          DestinationPort = 4789;
        };
      };
    };
in
lib.foldl'
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
      Address = ""
    };
  };
}
  (lib.imap0 buildInstance routerIds)
