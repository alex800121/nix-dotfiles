{ userConfit, pkgs, lib, ... }: {
  imports = [./default.nix];
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraSetFlags = [
    "--advertise-exit-node"
    "--accept-routes=true"
    "--advertise-routes=192.168.51.0/24,192.168.50.0/24"
  ];
}
