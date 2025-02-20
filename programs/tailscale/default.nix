{ config, userConfit, pkgs, lib, ... }: {
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  networking.firewall.trustedInterfaces = [
    config.services.tailscale.interfaceName
  ];
}
