{ pkgs, config, lib, userConfig, ... }:
let
  inherit (userConfig.keepalived) routers;
  inherit (config.networking) hostName;
  inherit (userConfig.tailscale) id peers;
  inherit (builtins) toString;
  inherit (lib) recursiveUpdate head tail map imap0 foldl';
  masterIp = "192.168.60.${toString id}/24";
  # masterTsIp = "100.64.0.${toString id}";
  peerTsIp = x: "100.64.0.${toString x}";
  initPrio = 100;
  updateScript = ''
    TS_API_TOKEN=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.tsApi.path})
    TS_NODE_ID=$(${pkgs.curl}/bin/curl --request GET \
                    --url https://api.tailscale.com/api/v2/tailnet/alex800121.github/devices \
                    -u "$TS_API_TOKEN:" \
                      | ${pkgs.jq}/bin/jq \
                          -r \
                          '.[].[] | select(.hostname=="${userConfig.hostName}").nodeId')
    OLD_VXLAN1_IP=$(${pkgs.curl}/bin/curl --request GET \
                      --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes \
                      -u "$TS_API_TOKEN:" \
                        | ${pkgs.jq}/bin/jq \
                            '.enabledRoutes | map(select((test("192\\.168\\.101") | not)))')
    NEW_VXLAN1_IP=$(${pkgs.iproute2}/bin/ip addr show dev vxlan1 \
                      | ${pkgs.gawk}/bin/awk '/192\.168\.101/{printf "\"" $2 "\""}' \
                      | ${pkgs.jq}/bin/jq \
                          -n \
                          --argjson data "$OLD_VXLAN1_IP" \
                          '{routes: ([inputs] + $data)}')
    ${pkgs.curl}/bin/curl --request POST \
      --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes \
      -u "$TS_API_TOKEN:" \
      --header 'Content-Type: application/json' \
      --data "$NEW_VXLAN1_IP"
    unset TS_API_TOKEN
  '';
  ids = toString id;
  renewIp = pkgs.writeScript "renew_ip.sh" updateScript;
  build = { id, priority }:
    ''
      vrrp_instance VW_${ids} {
        state BACKUP
        interface ${brName}
        track_process {
          track_vaultwarden
        }
        virtual_router_id ${ids}
        priority ${toString (initPrio - priority)}
        virtual_ipaddress {
          192.168.101.${ids}/32 dev ${brName} label ${brName}:vw${ids}
        }
        notify_master ${renewIp}
        notify_backup ${renewIp}
      }

    '';
  extraConfig =
    ''
      vrrp_track_process track_vaultwarden {
        process vaultwarden
        quorum 1
        weight 10
        delay 1
      }

    ''
    + lib.concatStrings (lib.map build routers);
  brName = "br${ids}";
  geneveConfig =
    foldl'
      (acc: x:
        let
          remote = toString x;
          combine = ids + remote;
          name = "gen${combine}";
        in
        recursiveUpdate acc
          {
            systemd.network.netdevs."${combine}-${name}" = {
              enable = true;
              netdevConfig = {
                Name = name;
                Kind = "geneve";
              };
              extraConfig = ''
                [GENEVE]
                Id=1
                Remote=${peerTsIp x}
              '';
            };
            systemd.network.networks."${combine}-${name}" = {
              enable = true;
              matchConfig = {
                Name = name;
              };
              bridge = [ brName ];
            };
          }
      )
      {
        systemd.network.netdevs."0${ids}-${brName}" = {
          enable = true;
          netdevConfig = {
            Name = brName;
            Kind = "bridge";
          };
        };
        systemd.network.networks."0${ids}-${brName}" = {
          enable = true;
          matchConfig = {
            Name = brName;
          };
          address = [
            masterIp
          ];
        };
      }
      peers;
in
{
  age.secrets.tsApi = {
    file = ../../secrets/tsapi.age;
    # file = ../../secrets/tsapi_${hostName}.age;
    owner = "root";
    group = "root";
    mode = "600";
  };
  environment.systemPackages = with pkgs; [
    keepalived
  ];
  systemd.network.enable = true;
  # systemd.network.netdevs."20-${name}" = {
  #   netdevConfig = {
  #     Name = name;
  #     Kind = "vxlan";
  #   };
  #   vxlanConfig = {
  #     VNI = networkId;
  #     Local = masterTsIp;
  #     MacLearning = true;
  #     DestinationPort = 4789;
  #     Independent = true;
  #   };
  # };
  # systemd.network.networks."20-${name}" = {
  #   matchConfig = {
  #     Name = name;
  #   };
  #   address = [
  #     "${masterIp}/24"
  #   ];
  #   bridgeFDBs = map
  #     (x: {
  #       Destination = peerTsIp x;
  #       VNI = networkId;
  #       MACAddress = "00:00:00:00:00:00";
  #     })
  #     peers;
  # };
  systemd.services.keepalived.postStop = updateScript;
  systemd.services.keepalived.postStart = updateScript;
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
  services.keepalived.extraConfig = extraConfig;
} // geneveConfig
