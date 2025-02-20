{ userConfit, pkgs, lib, ... }: {
  imports = [./default.nix];
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraSetFlags = [
    "--advertise-exit-node"
    "--advertise-routes=192.168.1.0/24"
  ];
}
