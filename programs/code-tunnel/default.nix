{ pkgs, userConfig, ... }: {
  systemd.user.services.code-tunnel = {
    enable = true;
# [Unit]
# Description=Visual Studio Code Tunnel
    description = "Visual Studio Code Tunnel";
# After=network.target
    after = [ "network.target" ];
# StartLimitIntervalSec=0
    startLimitIntervalSec = 0;

# [Service]
    serviceConfig = {
# Type=simple
      Type = "simple";
# Restart=always
      Restart = "always";
# RestartSec=10
      RestartSec = 10;
    };

    script = ''
      ${pkgs.vscode}/lib/vscode/bin/code-tunnel --verbose --cli-data-dir /home/${userConfig.userName}/.vscode-cli tunnel service internal-run
    '';
# ExecStart=/nix/store/02g2g1zrb48mmsy6ly28r0d5ssv52kl1-vscode-1.77.1/lib/vscode/bin/code-tunnel "--verbose" "--cli-data-dir" "/home/alex800121/.vscode-cli" "tunnel" "service" "internal-run"

# [Install]
    wantedBy = [ "default.target" ];
# WantedBy=default.target
  };
}
