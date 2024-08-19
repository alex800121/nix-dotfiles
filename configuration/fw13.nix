{ pkgs, nixpkgsUnstable, ... }:
let
  cfg = {
    matchConfig = {
      Name = "wlan0";
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
  boot.initrd.luks.devices."enc".preLVM = true;
  boot.initrd.luks.devices."enc".allowDiscards = true;
  boot.initrd.luks.devices."enc".bypassWorkqueues = true;
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  swapDevices = [ { device = "/swap/swapfile"; } ];

  systemd.network.networks."10-wlan0" = cfg;
  boot.initrd.systemd.network.networks."10-wlan0" = cfg;

  # networking.networkmanager.enable = false;
  # networking.networkmanager.unmanaged = [
  #   "*"
  # ];
  #
  # networking.useNetworkd = true;
  # networking.wireless.enable = false;
  # networking.wireless.iwd.enable = true;

  environment.systemPackages = with nixpkgsUnstable.gnomeExtensions; [
    xwayland-indicator
  ];
}
