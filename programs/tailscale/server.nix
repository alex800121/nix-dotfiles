{ userConfit, pkgs, lib, ... }: {
  imports = [ ./default.nix ];
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraSetFlags = [
    "--advertise-exit-node"
    "--accept-routes=true"
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
}
