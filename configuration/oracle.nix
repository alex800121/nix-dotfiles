{ conf, pkgs, config, userConfig, lib, inputs, nixpkgsUnstable, ... }:
let
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName hostName;
  inherit (pkgs) system;
  cfg = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      DHCP = true;
      # MulticastDNS = true;
      # LLMNR = true;
    };
    # linkConfig = {
    #   RequiredForOnline = true;
    #   RequiredFamilyForOnline = "any";
    #   Multicast = true;
    #   AllMulticast = true;
    # };
  };
in
{
  boot.kernelPackages = lib.mkDefault
    (if builtins.hasAttr "kernelVersion" conf
    then pkgs."linuxPackages_${conf.kernelVersion}"
    else pkgs.linuxPackages);
  imports =
    [
      # Include the results of the hardware scan.
      # ../hardware/oracle2.nix
      ../programs/sshd
      ../programs/tailscale/server.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = ''
        --delete-older-than 7d
      '';
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';
  };
  nix.settings.max-jobs = lib.mkDefault "auto";

  powerManagement.enable = false;
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall = {
    allowedUDPPorts = [ 5353 7236 ]; # For device discovery
  };
  services.resolved = {
    enable = true;
    llmnr = "true";
    extraConfig = ''
      MulticastDNS=resolve
    '';
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
    inherit hostName; # Define your hostname.
    networkmanager = {
      enable = lib.mkDefault true;
      dns = "systemd-resolved";
      connectionConfig = {
        "connection.mdns" = 1;
      };
      wifi.backend = "iwd";
    };
  };
  time.timeZone = lib.mkDefault "Asia/Singapore";
  i18n.defaultLocale = "en_US.utf8";

  users.mutableUsers = true;
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "networkmanager" "tss" "storage" "disk" "libvirtd" "audio" "systemd-network" "sudo" "wheel" "code-server" "input" ];
  };

  # boot.supportedFilesystems = [ "btrfs" "vfat" ];
  boot.kernelParams = [ "net.ifnames=0" ];
  boot.initrd = {
    availableKernelModules = [ "virtio-pci" ];
    systemd.users.root.shell = "/bin/sh";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.users.users."${userConfig.userName}".openssh.authorizedKeys.keys;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  };
  boot.initrd.luks.devices."enc".preLVM = true;
  boot.initrd.luks.devices."enc".allowDiscards = true;
  boot.initrd.luks.devices."enc".bypassWorkqueues = true;
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

  environment.systemPackages = with pkgs; [
    neovim
    wget
    btrfs-progs
    coreutils
    ripgrep
    parted
    curl
    fastfetch
    git
  ];
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  services.openssh.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?

}

