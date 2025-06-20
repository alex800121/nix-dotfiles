{ userConfig, config, pkgs, lib, ... }:
let
  inherit (userConfig.tailscale) id;
  tsIp = "100.64.0.${toString id}";
  updateServer = ''
    TS_API_TOKEN=$(cat ${config.age.secrets.tsServerApi.path})
    TS_INFO=$(curl \
                --request GET \
                --url https://api.tailscale.com/api/v2/tailnet/-/devices?fields=all \
                -u "$TS_API_TOKEN:" \
                    | jq '.[].[]
                            | select(.hostname=="${userConfig.hostName}")
                            | {
                                id: .nodeId,
                                ip: (.addresses.[] | select(startswith("100"))),
                                routes: [ (.enabledRoutes.[] 
                                            | select(.!="0.0.0.0/0" and .!="::/0")),
                                          "0.0.0.0/0",
                                          "::/0"
                                        ]
                              }')
    echo $TS_INFO

    TS_NODE_ID=$(echo $TS_INFO | jq -r .id)

    RESPONSE=$(curl --request POST \
                    --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/key \
                    -u "$TS_API_TOKEN:" \
                    --header 'Content-Type: application/json' \
                    --data "{\"keyExpiryDisabled\": true}")
    echo $RESPONSE
    echo "Expiry disabled"

    TS_ROUTES=$(echo $TS_INFO | jq -r '{routes}')
    RESPONSE=$(curl --request POST \
                    --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/routes \
                    -u "$TS_API_TOKEN:" \
                    --header 'Content-Type: application/json' \
                    --data "$TS_ROUTES")
    echo $RESPONSE
    echo "Advertised exit node"

    TS_NODE_IP=$(echo $TS_INFO | jq -r .ip)
    if [ "$TS_NODE_IP" != "${tsIp}" ]; then
      POST_IP="{\"ipv4\":\"${tsIp}\"}"
      RESPONSE=$(curl --request POST \
                      --url https://api.tailscale.com/api/v2/device/$TS_NODE_ID/ip \
                      -u "$TS_API_TOKEN:" \
                      --header 'Content-Type: application/json' \
                      --data "$POST_IP")
      echo $RESPONSE
      echo "Change tailscale server IP from $TS_NODE_IP to ${tsIp}"
    else
      echo "No need to set server IP"
    fi
    unset TS_API_TOKEN
  '';
in
{
  imports = [ ./default.nix ];
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraUpFlags = [
    "--advertise-routes="
  ];
  services.tailscale.extraSetFlags = [
    "--accept-routes=true"
    "--advertise-exit-node"
  ];
  systemd.services."tailscaled-set" = {
    requires = [ "tailscaled-autoconnect.service" "tailscaled.service" "network-online.target" ];
    after = [ "tailscaled-autoconnect.service" "tailscaled.service" "network-online.target" ];
  };
  systemd.services."tailscale-server-ip" = {
    enable = true;
    description = "Set tailscale server ip";
    wantedBy = [ "tailscaled.service" ];
    requires = [ "tailscaled-set.service" "tailscaled.service" "network-online.target" ];
    after = [ "tailscaled-set.service" "tailscaled.service" "network-online.target" ];
    restartIfChanged = true;
    path = with pkgs; [
      coreutils
      curl
      jq
    ];
    script = updateServer;
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
