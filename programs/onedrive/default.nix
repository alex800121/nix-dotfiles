{ pkgs, userConfig, ... }: {
  home.packages = [ pkgs.onedrive ];

  xdg.configFile = {
    onedrive = {
      recursive = true;
      source = ./.;
    };
  };

  systemd.user.services."onedrive" = {
    Unit.Description = "Onedrive sync service";
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.onedrive}/bin/onedrive --monitor --confdir=/home/${userConfig.userName}/.config/onedrive
      '';
      Restart = "on-failure";
      RestartSec = "3s";
      RestartPreventExitStatus=3;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    # script = ''
    #   ${pkgs.onedrive}/bin/onedrive --monitor --confdir=/home/${userName}/.config/onedrive
    # '';
    # serviceConfig = {
    #   Type = "simple";
    #   Restart = "on-failure";
    #   RestartSec = 3;
    # };
    # description = "Onedrive sync service";
    # wantedBy = [ "default.target" ];
  };
}
