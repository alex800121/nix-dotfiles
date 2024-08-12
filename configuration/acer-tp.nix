{ ... }:
let
  cfg = {
    matchConfig = {
      Name = "enp0s20f0u1u4";
    };
    networkConfig = {
      DHCP = true;
      MulticastDNS = true;
      LLMNR = true;
    };
    linkConfig = {
      RequiredForOnline = true;
      Multicast = true;
      AllMulticast = true;
    };
  };
in
{

  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  services.resolved = {
    enable = true;
    llmnr = "true";
    extraConfig = ''
      MulticastDNS=true
    '';
  };
  services.avahi.enable = false;

  systemd.network.networks."10-enp0s20f0u1u4" = cfg;
  boot.initrd.systemd.network.networks."10-enp0s20f0u1u4" = cfg;
}
