{ config, pkgs, ... }: let
  duckscript = pkgs.writeShellScript "duck.sh" ''
    ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=alexacer-tp&token=$(systemd-creds cat ddtoken)&ip="
  '';
  RuntimeDirectory = "duckdns";
in {
  users.groups.duckdns = {};
  users.extraUsers.duckdns = {
    name = "duckdns";
    group = "duckdns";
    isSystemUser = true;
  };
  age.secrets.ddtoken = {
    file = ../../secrets/ddtoken.age;
    owner = "duckdns";
    group = "duckdns";
  };

  systemd.services.duckdns = {
    enable = true;
    description = "duckdns update";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    restartTriggers = [ config.age.secrets.ddtoken.path ];
    path = [ pkgs.bash ];
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      RuntimeDirectoryMode = "0700";
      inherit RuntimeDirectory;
      LoadCredentialEncrypted = ''ddtoken:${config.age.secrets.ddtoken.path}'';
      ExecStart = duckscript;
    };
  };
  systemd.timers.duckdns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "5min";
      OnBootSec = "5min";
    };
  };
}