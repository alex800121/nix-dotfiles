{ pkgs, userConfig, ... }: {
  systemd.user.services.code-tunnel = {
    enable = true;
    description = "Visual Studio Code Tunnel";
    after = [ "network.target" ];
    startLimitIntervalSec = 0;
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
    };
    # path = [
    #   pkgs.bash
    # ];
    script = ''
      ${pkgs.vscode}/lib/vscode/bin/code-tunnel --verbose --cli-data-dir /home/${userConfig.userName}/.vscode-cli tunnel service internal-run
    '';
    wantedBy = [ "default.target" ];
  };
}
