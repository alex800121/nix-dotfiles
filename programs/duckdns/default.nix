{ config, pkgs, userConfig, ... }: let
  inherit (userConfig) hostName url;
  duckscript = pkgs.writeShellScript "duck.sh" ''
    echo "https://www.duckdns.org/update?domains=${url}&token=$(systemd-creds cat ddtoken)&ip=" | ${pkgs.curl}/bin/curl -k -K -
  '';
  RuntimeDirectory = "duckdns";
in {
  users.extraGroups.duckdns = {};
  users.extraUsers.duckdns = {
    name = "duckdns";
    group = "duckdns";
    isSystemUser = true;
  };
  age.secrets.ddtoken = {
    file = ../../secrets/ddtoken-${hostName}.age;
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
