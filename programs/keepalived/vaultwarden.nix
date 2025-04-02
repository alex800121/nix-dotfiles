{ pkgs, config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routerIds;
  inherit (userConfig) hostName;
  inherit (builtins) toString;
  inherit (lib) recursiveUpdate head tail map imap0 foldl';
  master = head routerIds;
  peers = tail routerIds;
  masterIp = "192.168.60.${toString master}";
  masterTsIp = "100.64.0.${toString master}";
  peerTsIp = x: "100.64.0.${toString x}";
  initPrio = 100;
  networkId = 1;
  name = "vxlan${toString networkId}";
  renewIp = pkgs.writeScript "renew_ip.sh" ''
    TS_API_TOKEN=$(cat ${config.age.secrets.tsApi.path})
    TS_NODE_ID=$(curl --request GET  \
                      --url https://api.tailscale.com/api/v2/tailnet/alex800121.github/devices -u "$TS_API_TOKEN:"  \
                        | ${pkgs.jq}/bin/jq -r '.[].[] | select(.hostname=="${userConfig.hostName}").nodeId')
    echo $TS_NODE_ID
    OLD_VXLAN1_IP=$(curl --request GET  \
                         --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes -u "$TS_API_TOKEN:"  \
                           | ${pkgs.jq}/bin/jq '.enabledRoutes | map(select((test("192\\.168\\.101") | not)))')
    echo $OLD_VXLAN1_IP
    NEW_VXLAN1_IP=$(ip addr show dev vxlan1 \
                      | awk '/192\.168\.101/{printf "\"" $2 "\""}'  \
                      | ${pkgs.jq}/bin/jq -n --argjson data "$OLD_VXLAN1_IP" '{routes: ([inputs] + $data)}')
    echo $NEW_VXLAN1_IP
    curl --request POST \
         --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes -u "$TS_API_TOKEN:"  \
         --header 'Content-Type: application/json'  \
         --data '$NEW_VXLAN1_IP'
    unset TS_API_TOKEN
  '';
  build = n: id:
    let
      ids = toString id;
    in
    {
      services.keepalived.vrrpInstances."VW_${ids}" = {
        priority = initPrio - n;
        state = if n == 0 then "MASTER" else "BACKUP";
        interface = name;
        virtualIps = [
          {
            addr = "192.168.101.${ids}/32";
            label = "${name}:vw${ids}";
          }
        ];
        virtualRouterId = id;
        extraConfig = ''
          notify_master ${renewIp}
          notify_backup ${renewIp}
        '';
      };
    };
  init = {

    age.secrets.tsApi = {
      file = ../../secrets/tsapi_${hostName}.age;
      owner = "root";
      group = "root";
      mode = "600";
    };
    environment.systemPackages = with pkgs; [
      keepalived
    ];
    systemd.network.enable = true;
    systemd.network.netdevs."20-${name}" = {
      netdevConfig = {
        Name = name;
        Kind = "vxlan";
      };
      vxlanConfig = {
        VNI = networkId;
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
      address = [
        "${masterIp}/24"
      ];
      bridgeFDBs = map
        (x: {
          Destination = peerTsIp x;
          VNI = networkId;
          MACAddress = "00:00:00:00:00:00";
        })
        peers;
    };
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
  };
in
foldl' recursiveUpdate init (imap0 build routerIds)
