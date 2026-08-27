{ self, ... }: {
  flake.nixosModules.keepalived-vaultwarden =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config.initConfig) id;
      inherit (builtins) toString;
      masterIds = toString id;
      masterIp = "192.168.60.${masterIds}/24";
      masterTsIp = config.services.tailscale.server.ip;
      peerTsIp = x: self.nixosConfigurations."${x}".config.services.tailscale.server.ip;
      initPrio = 100;
      updateScript = ''
        TS_ID=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.tsid.path})
        TS_SECRET=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.tssecret.path})
        TS_API_TOKEN=$(${pkgs.curl}/bin/curl -d "client_id=$TS_ID" -d "client_secret=$TS_SECRET" "https://api.tailscale.com/api/v2/oauth/token" | ${pkgs.jq}/bin/jq .access_token -r)
        TS_NODE_ID=$(${pkgs.curl}/bin/curl --request GET \
                        --url https://api.tailscale.com/api/v2/tailnet/alex800121.github/devices \
                        -u "$TS_API_TOKEN:" \
                          | ${pkgs.jq}/bin/jq \
                              -r \
                              '.[].[] | select(.hostname=="${config.networking.hostName}").nodeId')
        OLD_VXLAN_IP=$(${pkgs.curl}/bin/curl --request GET \
                          --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes \
                          -u "$TS_API_TOKEN:" \
                            | ${pkgs.jq}/bin/jq \
                                '.enabledRoutes | map(select((test("192\\.168\\.101") | not)))')
        NEW_VXLAN_IP=$(${pkgs.iproute2}/bin/ip addr show dev ${brName} \
                          | ${pkgs.gawk}/bin/awk '/192\.168\.101/{printf "\"" $2 "\""}' \
                          | ${pkgs.jq}/bin/jq \
                              -n \
                              --argjson data "$OLD_VXLAN_IP" \
                              '{routes: ([inputs] + $data)}')
        ${pkgs.curl}/bin/curl --request POST \
          --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes \
          -u "$TS_API_TOKEN:" \
          --header 'Content-Type: application/json' \
          --data "$NEW_VXLAN_IP"
        unset TS_API_TOKEN
        unset TS_SECRET
        unset TS_ID
      '';
      renewIp = pkgs.writeScript "renew_ip.sh" updateScript;
      extraConfig =
        let
          vwInstance = toString (config.services.vaultwarden.galera.tailscale.keepalived.router.id);
          inherit (config.services.vaultwarden.galera.tailscale.keepalived.router) priority;
        in
        ''
          vrrp_track_process track_vaultwarden {
            process vaultwarden
            quorum 1
            weight 10
            delay 1
          }
          vrrp_instance VW_${vwInstance} {
            state BACKUP
            interface ${brName}
            track_process {
              track_vaultwarden
            }
            advert_int 1
            virtual_router_id ${vwInstance}
            priority ${toString (initPrio - priority)}
            virtual_ipaddress {
              192.168.101.${vwInstance}/32 dev ${brName} label ${brName}:vw${vwInstance}
            }
            notify ${renewIp}
          }
        '';
      brName = "br${masterIds}";
      vxlanName = "vxlan${toString networkId}";
      networkId = 1;
    in
    {
      options = {
        services.vaultwarden.galera.tailscale.keepalived.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        services.vaultwarden.galera.tailscale.keepalived.peers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = config.services.vaultwarden.galera.peers or [ ];
        };
        services.vaultwarden.galera.tailscale.keepalived.router.id = lib.mkOption {
          type = lib.types.nullOr lib.types.ints.u8;
          default = config.initConfig.topo."${config.networking.hostName}".keepalived.router.id or null;
        };
        services.vaultwarden.galera.tailscale.keepalived.router.priority = lib.mkOption {
          type = lib.types.nullOr lib.types.ints.u8;
          default = config.initConfig.topo."${config.networking.hostName}".keepalived.router.priority or null;
        };
      };
      config = lib.mkIf config.services.vaultwarden.galera.tailscale.keepalived.enable {
        age.secrets."tssecret" = {
          file = ../../../secrets/tssecret.age;
        };
        age.secrets."tsid" = {
          file = ../../../secrets/tsid.age;
        };
        environment.systemPackages = with pkgs; [
          keepalived
        ];
        systemd.network.enable = true;
        systemd.network.netdevs."0${masterIds}-${brName}" = {
          enable = true;
          netdevConfig = {
            Name = brName;
            Kind = "bridge";
          };
        };
        systemd.network.networks."0${masterIds}-${brName}" = {
          enable = true;
          matchConfig = {
            Name = brName;
          };
          address = [
            masterIp
          ];
        };
        systemd.network.netdevs."20-${vxlanName}" = {
          netdevConfig = {
            Name = vxlanName;
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
        systemd.network.networks."20-${vxlanName}" = {
          matchConfig = {
            Name = vxlanName;
          };
          bridge = [ brName ];
          bridgeFDBs = map (x: {
            Destination = peerTsIp x;
            VNI = networkId;
            MACAddress = "00:00:00:00:00:00";
          }) config.services.vaultwarden.galera.tailscale.keepalived.peers;
        };
        systemd.services.keepalived.wants = [
          "tailscale-server-ip.service"
          "network-online.target"
          "tailscaled.service"
        ];
        systemd.services.keepalived.after = [
          "tailscale-server-ip.service"
          "network-online.target"
          "tailscaled.service"
        ];
        systemd.services.keepalived.requires = [
          "tailscale-server-ip.service"
          "network-online.target"
          "tailscaled.service"
        ];
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

        services.tailscale.extraSetFlags = [
          "--advertise-routes=192.168.101.${toString config.services.vaultwarden.galera.tailscale.keepalived.router.id}/32"
        ];

      };
    };
}
