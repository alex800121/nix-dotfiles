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
      RequiredFamilyForOnline = "any";
      Multicast = true;
      AllMulticast = true;
    };
  };
in
{
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.wait-online.anyInterface = false;

  systemd.network.networks."10-enp0s20f0u1u4" = cfg;
  boot.initrd.systemd.network.networks."10-enp0s20f0u1u4" = cfg;
}
