{ userConfig, config, pkgs, lib, ... }:
let
  inherit (userConfig.tailscale) id;
  tsIp = "100.64.0.${toString id}";
  updateServerIp = ''
    TS_API_TOKEN=$(cat ${config.age.secrets.tsServerApi.path})
    TS_ID_IP=$(curl --request GET \
                      --url https://api.tailscale.com/api/v2/tailnet/-/devices?fields=default \
                      -u "$TS_API_TOKEN:" \
                        | jq '.[].[] | select(.hostname=="${userConfig.hostName}") 
                                    | {id: .nodeId, addr: (.addresses.[] | select(test("100")))}')
    TS_NODE_IP=$(echo $TS_ID_IP | jq -r .addr)
    if [ "$TS_NODE_IP" != "${tsIp}" ]; then
      TS_NODE_ID=$(echo $TS_ID_IP | jq -r .id)
      POST_IP="{\"ipv4\":\"${tsIp}\"}"
      curl --request POST \
          --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/ip \
          -u "$TS_API_TOKEN:" \
          --header 'Content-Type: application/json' \
          --data "$POST_IP"
      echo "Change tailscale server IP from $TS_NODE_IP to ${tsIp}"
    else
      echo "No need to set IP"
    fi
    unset TS_API_TOKEN
  '';
in
{
  imports = [ ./default.nix ];
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraUpFlags = [
    ''--advertise-routes=""''
  ];
  services.tailscale.extraSetFlags = [
    "--advertise-exit-node"
    "--accept-routes=true"
  ];

  systemd.services."tailscale-server-ip" = {
    enable = true;
    description = "Set tailscale server ip";
    wantedBy = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" "network-online.target" ];
    after = [ "tailscaled.service" "network-online.target" ];
    path = with pkgs; [
      coreutils
      curl
      jq
    ];
    script = updateServerIp;
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
  age.secrets.tsServerApi = {
    file = ../../secrets/tsapi.age;
    # file = ../../secrets/tsapi_${hostName}.age;
    owner = "root";
    group = "root";
    mode = "600";
  };
}
