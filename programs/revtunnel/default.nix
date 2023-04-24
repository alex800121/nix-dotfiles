{ pkgs, userConfig, ... }: {
  systemd.user.services.revtunnel = {
    enable = true;
    description = "Reverse tunnel for acer-nixos";
    after = [ "network.target" "home-manager-${userConfig.userName}.service" ];
    script = ''
      ${pkgs.openssh}/bin/ssh -vvv -N -T -o "ExitOnForwardFailure=yes" \
      -o "UserKnownHostsFile=/home/${userConfig.userName}/.ssh/known_hosts" -R 51000:localhost:22 \
      alex800121@alexrpi4gate.duckdns.org -p 31000
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
  };
}