{ config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routerIds;
  initPrio = 100;
  buildInstance = n: id:
    let ids = builtins.toString id; in {
      services.keepalived.vrrpInstances."VW_${ids}" = {
        priority = initPrio + n;
        state = if n == 0 then "MASTER" else "BACKUP";
        interface = "vxlan1";
        virtualIps = [
          {
            addr = "192.168.50.${ids}/24";
            label = "vxlan1:vw${ids}";
          }
        ];
        virtualRouterId = id;
      };
      services.keepalived.vrrpInstances."VW_DB_${ids}" = {
        priority = initPrio + n;
        state = if n == 0 then "MASTER" else "BACKUP";
        interface = "vxlan1";
        virtualIps = [
          {
            addr = "192.168.51.${ids}/24";
            label = "vxlan1:db${ids}";
          }
        ];
        virtualRouterId = id + 100;
        # unicastPeers = [
        #   "100.99.202.117"
        #   "100.112.159.45"
        #   "100.111.136.66"
        # ];
      };
    };
in
lib.foldl'
  lib.recursiveUpdate
{
  services.keepalived.enable = true;
}
  (lib.imap0 buildInstance routerIds)
