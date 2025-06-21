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
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      ../hardware/disko/oracle2.nix
      ../hardware/oracle2.nix
      ./distributed-builds.nix
      ../programs/tailscale/server.nix
      ../programs/sshd
      ../programs/seaweedfs
      # ../programs/vaultwarden
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
      # enable = lib.mkDefault true;
      dns = "systemd-resolved";
      connectionConfig = {
        "connection.mdns" = 1;
      };
      wifi.backend = "iwd";
    };
  };
  time.timeZone = lib.mkDefault "Asia/Singapore";
  i18n.defaultLocale = "en_US.UTF-8";
  programs.bash = {
    completion.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alh";
      la = "ls -A";
      l = "ls -CF";
      nv = "nvim";
    };
    enableLsColors = true;
    vteIntegration = true;
    interactiveShellInit = ''
      HISTCONTROL=ignorespace:ignoreboth
      HISTSIZE=100000
      HISTFILESIZE=100000
      shopt -s histappend

      shopt -s checkwinsize
      shopt -s extglob
      shopt -s globstar
      shopt -s checkjobs
      shopt -s cdspell
      shopt -o -s vi
    '';
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        USER_COLOR="1;31"
        ((UID)) && USER_COLOR="1;32"
        PS1="\n\[\e[\[$USER_COLOR\]m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w \$\[\e[0m\] "
        if [ -z "$INSIDE_EMACS" ]; then
          PS1="\[\e]0;\u@\h:\w\a\]$PS1"
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\e]2;\h:\u:\w\007\]$PS1"
        fi
      fi
    '';
  };

  users.mutableUsers = true;
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "networkmanager" "tss" "storage" "disk" "libvirtd" "audio" "systemd-network" "sudo" "wheel" "code-server" "input" ];
    initialPassword = "";
    uid = 1000;
  };
  users.groups.users.gid = 100;
  security.sudo.wheelNeedsPassword = false;

  # boot.supportedFilesystems = [ "btrfs" "vfat" ];
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

  documentation.man.generateCaches = true;

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
    inputs.agenix.packages.${system}.default
    wl-clipboard
    jq
    lemonade
  ];
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
