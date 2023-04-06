{ pkgs, ... }: {
  systemd.user.services.revtunnel = {
    enable = true;
    description = "Reverse tunnel for acer-nixos";
    after = [ "network.target" "home-manager-alex800121.service" ];
    script = ''
      ${pkgs.openssh}/bin/ssh -vvv -N -T -o "ExitOnForwardFailure=yes" \
      -o "UserKnownHostsFile=/home/alex800121/.ssh/known_hosts" -R 60000:127.0.0.1:4444 -R 50000:127.0.0.1:22 \
      alex800121@alexrpi4gate.ubddns.org -p 30000
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
  };
}