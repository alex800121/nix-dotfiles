{ ... }:
let
  cfg = {
    matchConfig = {
      Name = "wlan0";
    };
    domains = [
      "duckdns.org"
    ];
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
  boot.initrd.luks.devices = {
    ENCRYPTED = {
      device = "/dev/disk/by-uuid/aebaf441-09a4-410f-9f23-22858f02ab3f";
      preLVM = true;
      allowDiscards = true;
      bypassWorkqueues = true;
    };
  };

  systemd.network.networks."10-wlan0" = cfg;
  boot.initrd.systemd.network.networks."10-wlan0" = cfg;

  networking.networkmanager.unmanaged = [
    "*"
  ];

  networking.useNetworkd = true;
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;

}
