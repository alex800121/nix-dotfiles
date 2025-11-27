{ inputs, userConfig, lib, pkgs, ... }:
let
  inherit (userConfig) userName hostName;
in
{
  imports = [
    ../programs/sshd
    ../programs/kmscon
    ../programs/bash
  ];

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

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

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  # Set your time zone.
  time.timeZone = lib.mkDefault "Asia/Taipei";
  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = true;
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "networkmanager" "tss" "storage" "disk" "libvirtd" "audio" "systemd-network" "sudo" "wheel" "code-server" "input" ];
    uid = 1000;
    initialPassword = "";
  };
  users.groups.users.gid = 100;
  security.sudo.wheelNeedsPassword = false;

  environment.etc.inputrc = {
    enable = true;
    source = ./inputrc;
  };

  environment.systemPackages = with pkgs; [
    coreutils
    parted
    inputs.agenix.packages.${system}.default
    ripgrep
    neovim
    curl
    wget
    git
    btrfs-progs
    wl-clipboard
    jq
    lemonade
    btop
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  networking.wireless.iwd.enable = true;

  networking.hostName = hostName;

  system.stateVersion = lib.mkDefault "25.11";
}
