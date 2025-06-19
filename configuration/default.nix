# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, config, lib, userConfig, inputs, nixpkgsUnstable, conf, ... }:
let
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName hostName;
  inherit (pkgs) system;
in
{
  system.stateVersion = lib.mkDefault "25.05";
  boot.binfmt.emulatedSystems = builtins.filter (x: x != system) [
    "aarch64-linux"
    "x86_64-linux"
  ];
  boot.kernelPackages = lib.mkDefault
    (if builtins.hasAttr "kernelVersion" conf
    then pkgs."linuxPackages_${conf.kernelVersion}"
    else pkgs.linuxPackages);

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.acpilight.enable = true;

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  services.gpm.enable = true;

  services.kmscon.enable = true;
  # services.kmscon.autologinUser = userName;
  services.kmscon.hwRender = true;
  services.kmscon.extraConfig = ''
    font-size=14
  '';
  services.kmscon.fonts = [
    {
      name = "Hack Nerd Font Mono";
      package = pkgs.nerd-fonts.hack;
    }
  ];

  # Bootloader.
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.consoleMode = lib.mkDefault "auto";
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

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

  services.power-profiles-daemon.enable = lib.mkDefault true;

  powerManagement.enable = true;

  networking.firewall.enable = lib.mkDefault true;
  networking.firewall = {
    allowedUDPPorts = [
      # 5353
      # 7236
    ]; # For device discovery
    # allowedTCPPortRanges = [{ from = 32768; to = 61000; }]; # For Streaming
    # allowedTCPPorts = [ 8010 7236 7250]; # For gnomecast server
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
  # networking.nftables.enable = true;

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
  systemd.network.wait-online.enable = lib.mkDefault (!config.networking.networkmanager.enable);
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.hardwareClockInLocalTime = lib.mkDefault true;
  services.automatic-timezoned.enable = lib.mkDefault false;
  time.timeZone = lib.mkDefault "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-chewing
        fcitx5-chinese-addons
        fcitx5-configtool
        fcitx5-gtk
        libsForQt5.fcitx5-qt
        # fcitx5-rime
      ];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  security.rtkit.enable = true;

  # security.tpm2.enable = true;
  # security.tpm2.abrmd.enable = true;
  # security.tpm2.pkcs11.enable = true;
  # security.tpm2.tctiEnvironment.enable = true;

  # hardware.pulseaudio.enable = false;
  # services.pipewire.socketActivation = true;
  # services.pipewire.systemWide = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    mouse.additionalOptions = "Option \"HighResolutionWheelScrolling\" \"false\"\n";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.hack
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      wqy_zenhei
      wqy_microhei
      vistafonts-cht
      font-awesome
      cantarell-fonts
      liberation_ttf
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK TC" "Ubuntu" ];
        sansSerif = [ "Noto Sans CJK TC" "Ubuntu" ];
        monospace = [ "Noto Sans Mono CJK TC" "Ubuntu" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "networkmanager" "tss" "storage" "disk" "libvirtd" "audio" "systemd-network" "sudo" "wheel" "code-server" "input" ];
    uid = 1000;
  };
  users.groups.users.gid = 100;

  security.sudo.wheelNeedsPassword = false;

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      pulseaudio = true;
    };
  };

  services.usbmuxd.enable = true;

  # Allow unfree packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btrfs-progs
    firefox
    coreutils
    socat
    jq
    wl-clipboard
    lemonade
    ripgrep
    gparted
    parted
    adwaita-icon-theme
    neovim
    curl
    wget
    git
    git-filter-repo
    inputs.agenix.packages."${system}".default
    fastfetch
    gcc
    conntrack-tools
  ];

  programs.localsend.enable = true;
  programs.localsend.openFirewall = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "Adwaita";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # Enable the Locate
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
    # prunePaths = [ "/media/alex800121" ];
  };

  qt = {
    enable = true;
    style = "adwaita-dark";
  };

  services.hoogle = {
    enable = true;
    packages = hp: with hp; [
    ];
  };
} 
