{ userConfit, pkgs, lib, ... }: {
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
}
