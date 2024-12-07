{ userConfit, pkgs, lib, ... }: {
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.extraSetFlags = [
    "--exit-node=alexrpi4tp"
    "--exit-node-allow-lan-access=true"
    "--accept-routes=true"
  ];
}
