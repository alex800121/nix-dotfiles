{ config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routerIds;
  master = "192.168.53.${builtins.toString (lib.head routerIds)}";
  peers = lib.map (x: "192.168.53.${builtins.toString x}") (lib.tail routerIds);
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
        unicastSrcIp = master;
        unicastPeers = peers;
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
        unicastSrcIp = master;
        unicastPeers = peers;
      };
    };
in
lib.foldl'
  lib.recursiveUpdate
{
  services.keepalived.enable = true;
  services.keepalived.openFirewall = true;
}
  (lib.imap0 buildInstance routerIds)
