{ pkgs, ... }: {
  systemd.user.services.duckdns = {
    enable = true;
    description = "Duckdns update";
    wantedBy = [
      "default.target"
    ];
    after = [
      "network.target"
    ];
    path = [
      pkgs.curl
    ];
    script = ''
      curl -k -o ~/duck.log "https://www.duckdns.org/update?domains=alexrpi4gate&token=fb3b6437-b770-4b59-9daf-4097801ed20a&ip="
    '';
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
  systemd.user.timers.duckdns = {
    timerConfig = {
      OnUnitActiveSec = "5min";
      OnBootSec = "5min";
      # Unit = "duckdns.service";
    };
  };
}