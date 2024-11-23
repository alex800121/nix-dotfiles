{ inputs, nixpkgsUnstable, ... }:
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
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./timezoned.nix
    ./secure-boot.nix
    ./distributed-builds.nix
    ./default.nix
    ../hardware/amd.nix
    ../hardware/fw13.nix
    ../hardware/laptop.nix
    ../de/gnome
    ../de/gnome/fw13
    ../programs/sshd
    ../programs/virt
    ../programs/tailscale/client.nix
  ];

  boot.initrd.luks.devices."enc".preLVM = true;
  boot.initrd.luks.devices."enc".allowDiscards = true;
  boot.initrd.luks.devices."enc".bypassWorkqueues = true;
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  swapDevices = [{ device = "/swap/swapfile"; }];

  systemd.network.networks."10-wlan0" = cfg;
  boot.initrd.systemd.network.networks."10-wlan0" = cfg;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;

  # networking.networkmanager.enable = false;
  # networking.networkmanager.unmanaged = [
  #   "*"
  # ];
  # networking.useNetworkd = true;
  # networking.wireless.enable = false;
  # networking.wireless.iwd.enable = true;

  services.ollama.enable = true;
  services.ollama.package = nixpkgsUnstable.ollama;
  services.ollama.acceleration = "rocm";
}
