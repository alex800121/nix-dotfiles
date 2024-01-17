{ pkgs, userConfig, ... }: {
  systemd.user.services.revtunnel = {
    enable = true;
    description = "Reverse tunnel for ${userConfig.hostName}";
    after = [ "network.target" "home-manager-${userConfig.userName}.service" ];
    script = ''
      ${pkgs.openssh}/bin/ssh -vvv -N -T -o "ExitOnForwardFailure=yes" \
      -o "UserKnownHostsFile=/home/${userConfig.userName}/.ssh/known_hosts" -R 0.0.0.0:${userConfig.port}:localhost:22 \
      -o "StrictHostKeyChecking=no" \
      ${userConfig.userName}@${userConfig.revConfig.url}.duckdns.org -p ${userConfig.revConfig.port}
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
  };
}
