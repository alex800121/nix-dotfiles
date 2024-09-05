{ userConfit, pkgs, lib, ... }: {
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.extraSetFlags = [
    "--exit-node=acer-tp"
    "--exit-node-allow-lan-access=true"
  ];
}
