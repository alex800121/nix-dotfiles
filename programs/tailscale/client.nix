{ userConfig, pkgs, lib, ... }: {
  imports = [./default.nix];
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.extraSetFlags = [
    "--exit-node=alexrpi4tp"
    "--exit-node-allow-lan-access=true"
    "--accept-routes=true"
  ];
}
