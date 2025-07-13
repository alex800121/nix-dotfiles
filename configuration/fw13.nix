{ inputs, pkgs, ... }:
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
    ./default.nix
    ./timezoned.nix
    # ./secure-boot.nix
    ./distributed-builds.nix
    ./ssh-serve.nix
    ../hardware/amd.nix
    ../hardware/fw13.nix
    ../hardware/laptop.nix
    ../de/gnome
    ../de/gnome/fw13
    ../programs/seaweedfs
    ../programs/virt
    ../programs/tailscale/client.nix
    ../programs/postgresql
    inputs.agenix.nixosModules.default
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

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  environment.systemPackages = with pkgs; [
    gnome-software
  ];
}
