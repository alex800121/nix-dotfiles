{ userConfit, pkgs, lib, ... }: {
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraSetFlags = [
    "--advertise-exit-node"
    "--advertise-routes=192.168.1.0/24"
  ];
}
