{ lib, pkgs, url, config, ... }:
let
  setCred = "ddtoken:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../../secrets/ddtoken-${config.networking.hostName}));
in
{

  systemd.services.duckdns = {
    enable = true;
    description = "duckdns update";
    wantedBy = [ "default.target" ];
    after = [ "systemd-networkd-wait-online.service" "network-online.target" ];
    wants = [ "systemd-networkd-wait-online.service" "network-online.target" ];
    path = [ pkgs.bash ];
    script = ''
      ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=${url}&token=$(cat $CREDENTIALS_DIRECTORY/ddtoken)&ip=" 
    '';
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      RuntimeDirectoryMode = "0700";
      RuntimeDirectory = "duckdns";
      SetCredentialEncrypted = setCred;
      Restart = "on-failure";
      RestartSec = "5s";
    };
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

  systemd.timers.duckdns = {
    wantedBy = [ "timers.target" ];
    after = [ "systemd-networkd-wait-online.service" "network-online.target" ];
    wants = [ "systemd-networkd-wait-online.service" "network-online.target" ];
    timerConfig = {
      OnUnitActiveSec = "5min";
      OnBootSec = "5min";
    };
  };
}
