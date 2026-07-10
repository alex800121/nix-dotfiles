{ pkgs, config, lib, inputs, ... }:
let
  cfg = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      DHCP = true;
    };
  };
in
{
  imports =
    [
      ./common.nix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      ../hardware/disko/oracle.nix
      ../hardware/oracle.nix
      ./distributed-builds.nix
      ../programs/tailscale/server.nix
      # ../programs/seaweedfs
    ../programs/nvim/minimal.nix
    ];

  initConfig.defaultUser = "alex800121";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  powerManagement.enable = false;
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall = {
    allowedUDPPorts = [
      # 5353
      # 7236
    ]; # For device discovery
  };
  networking.networkmanager.enable = false;
  boot.kernelParams = [ "net.ifnames=0" ];
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-eth0" = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      DHCP = true;
      MulticastDNS = true;
      LLMNR = true;
    };
    linkConfig = {
      Multicast = true;
      AllMulticast = true;
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve.LLMNR = true;
    settings.Resolve.MulticastDNS = "resolve";
  };

  services.avahi = {
    publish.enable = true;
    publish.hinfo = true;
    publish.addresses = true;
    publish.domain = true;
    publish.workstation = true;
    publish.userServices = true;
  };

  networking = {
    networkmanager = {
      # enable = lib.mkDefault true;
      dns = "systemd-resolved";
      connectionConfig = {
        "connection.mdns" = 1;
      };
      wifi.backend = "iwd";
    };
  };

  time.timeZone = "Asia/Singapore";

  # boot.supportedFilesystems = [ "btrfs" "vfat" ];
  boot.initrd = {
    availableKernelModules = [ "virtio-pci" ];
    systemd.users.root.shell = "/bin/sh";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.users.users."${config.initConfig.defaultUser}".openssh.authorizedKeys.keys;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  };
  # boot.initrd.luks.devices."enc".preLVM = true;
  # boot.initrd.luks.devices."enc".allowDiscards = true;
  # boot.initrd.luks.devices."enc".bypassWorkqueues = true;
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  swapDevices = [{ device = "/swap/swapfile"; }];
  systemd.network.networks."00-eth0" = cfg;
  boot.initrd.systemd.network.networks."00-eth0" = cfg;
  boot.initrd.network.flushBeforeStage2 = true;
  boot.initrd.systemd.enable = true;
  # boot.initrd.systemd.tpm2.enable = true;

  documentation.man.enable = true;
  documentation.man.cache.enable = true;
  documentation.man.cache.generateAtRuntime = true;
}
