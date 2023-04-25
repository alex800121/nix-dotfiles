{ config, pkgs, ... }: let
  duckscript = pkgs.writeShellScript "duck.sh" ''
    ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=alexacer-tp&token=@password_placeholder@&ip="
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
    path = [ pkgs.bash pkgs.coreutils-full pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      RuntimeDirectoryMode = "0700";
      inherit RuntimeDirectory;
      ExecStartPre = [
        ''${pkgs.coreutils-full}/bin/install ${duckscript} /run/${RuntimeDirectory}/duck.sh''
        ''${pkgs.gnused}/bin/sed -i "s#@password_placeholder@#$(${pkgs.coreutils-full}/bin/cat "${config.age.secrets.ddtoken.path}")#" "/run/${RuntimeDirectory}/duck.sh"''
        ''${pkgs.coreutils-full}/bin/cat /run/${RuntimeDirectory}/duck.sh''
      ];
      ExecStart = ''
        /run/${RuntimeDirectory}/duck.sh
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