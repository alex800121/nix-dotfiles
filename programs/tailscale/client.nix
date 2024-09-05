{ userConfit, pkgs, lib, ... }: {
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.extraSetFlags = [
    "--exit-node=100.111.136.66"
    "--exit-node-allow-lan-access=true"
  ];
}
