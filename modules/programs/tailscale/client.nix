{ self, ... }:
{
  flake.nixosModules.tailscale-client = { pkgs, ... }: {
    imports = [ self.nixosModules.tailscale ];
    services.tailscale.useRoutingFeatures = "client";
    services.tailscale.extraSetFlags = [
      "--exit-node-allow-lan-access=true"
      "--accept-routes=true"
    ];
    systemd.user.services.tailscale-systray = {
      description = "Tailscale System Tray";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      script = "${pkgs.tailscale}/bin/tailscale systray";
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };
}
