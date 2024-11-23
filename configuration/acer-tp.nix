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
      RequiredForOnline = true;
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
    ../programs/duckdns
    ../programs/duckdns/initrd.nix
    ../programs/tailscale/server.nix
  ];

  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.wait-online.anyInterface = false;

  systemd.network.networks."10-enp0s20f0u1u4" = cfg;
  boot.initrd.systemd.network.networks."10-enp0s20f0u1u4" = cfg;

  boot.initrd.systemd.contents = {
    "/etc/tmpfiles.d/resolv.conf".text =
      "L /etc/resolv.conf - - - - /run/systemd/resolve/stub-resolv.conf";
    "/etc/systemd/resolved.conf".text = resolvedConf;
  };

  boot.initrd.systemd.additionalUpstreamUnits = [ "systemd-resolved.service" ];
  boot.initrd.systemd.users.systemd-resolve = { };
  boot.initrd.systemd.groups.systemd-resolve = { };
  boot.initrd.systemd.storePaths = [ "${pkgs.systemd}/lib/systemd/systemd-resolved" ];
  boot.initrd.systemd.services.systemd-resolved = {
    wantedBy = [ "sysinit.target" ];
    aliases = [ "dbus-org.freedesktop.resolve1.service" ];
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;

  boot.initrd.luks.devices."enc".preLVM = true;
  boot.initrd.luks.devices."enc".allowDiscards = true;
  boot.initrd.luks.devices."enc".bypassWorkqueues = true;
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  swapDevices = [{ device = "/swap/swapfile"; }];
}
