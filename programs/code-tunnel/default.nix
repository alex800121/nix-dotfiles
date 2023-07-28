{ pkgs, userConfig, inputs, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable { inherit (pkgs) system; config.allowUnfree = true; };
in {
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
    path = [
      "/run/wrappers/"
      "/home/${userConfig.userName}/.nix-profile/"
      "/etc/profiles/per-user/${userConfig.userName}/"
      "/nix/var/nix/profiles/default/"
      "/run/current-system/sw/"
    ];
    preStart = ''
      echo $PATH
      /usr/bin/env
    '';
    script = ''
      ${nixpkgsUnstable.vscode}/lib/vscode/bin/code-tunnel --verbose --log trace --cli-data-dir /home/${userConfig.userName}/.vscode-cli tunnel service internal-run
    '';
    wantedBy = [ "default.target" ];
  };
}
