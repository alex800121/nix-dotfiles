{ pkgs, ... }:
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
      # RequiredForOnline = true;
      RequiredFamilyForOnline = "any";
      Multicast = true;
      AllMulticast = true;
    };
  };

  resolvedConf = ''
    [Resolve]
  '';
in
{
  imports = [
    ./default.nix
    ./secure-boot.nix
    ./distributed-builds.nix
    ./timezoned.nix
    ./initrd-network.nix
    ../hardware/acer-tp.nix
    ../hardware/desktop.nix
    ../de/gnome
    ../programs/nix-ld
    ../programs/code-tunnel
    ../programs/sshd
    ../programs/virt
    # ../programs/duckdns
    # ../programs/duckdns/initrd.nix
    ../programs/tailscale/server.nix
    ../programs/borgbackup/server.nix
  ];

  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.wait-online.anyInterface = false;
  systemd.network.wait-online.ignoredInterfaces = [ "wlp0s20f3" ];

  systemd.network.networks."10-enp0s20f0u1u4" = cfg;
  boot.initrd.systemd.network.networks."10-enp0s20f0u1u4" = cfg;

  boot.initrd.luks.devices."enc".preLVM = true;
  boot.initrd.luks.devices."enc".allowDiscards = true;
  boot.initrd.luks.devices."enc".bypassWorkqueues = true;
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  swapDevices = [{ device = "/swap/swapfile"; }];
}
