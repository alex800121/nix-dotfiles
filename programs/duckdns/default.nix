{ config, pkgs, userConfig, ... }: {
  users.extraGroups.duckdns = { };
  users.extraUsers.duckdns = {
    name = "duckdns";
    group = "duckdns";
    isSystemUser = true;
  };
  age.secrets.ddtoken = {
    file = ../../secrets/ddtoken-${userConfig.hostName}.age;
    owner = "duckdns";
    group = "duckdns";
    mode = "0600";
  };

  systemd.services.duckdns = {
    enable = true;
    description = "duckdns update";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    restartTriggers = [ config.age.secrets.ddtoken.path ];
    path = [ pkgs.bash ];
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      RuntimeDirectoryMode = "0700";
      RuntimeDirectory = "duckdns";
      LoadCredentialEncrypted = ''ddtoken:${config.age.secrets.ddtoken.path}'';
      ExecStart = pkgs.writeShellScript "duck.sh" ''
        ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=${userConfig.url}&token=$(cat $CREDENTIALS_DIRECTORY/ddtoken)&ip=" 
      '';
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
