# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, lib, userConfig, inputs, kernelVersion, nixpkgsUnstable, nixpkgs_x86, ... }:
let
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName hostName;
  inherit (pkgs) system;
in
{
  system.stateVersion = lib.mkDefault "24.05";
  boot.binfmt.emulatedSystems = builtins.filter (x: x != system) [
    "aarch64-linux"
    "x86_64-linux"
  ];
  boot.kernelPackages = lib.mkDefault pkgs."linuxPackages_${kernelVersion}";

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  hardware.acpilight.enable = true;

  services.fwupd.enable = true;

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  services.kmscon.enable = true;
  # services.kmscon.autologinUser = userName;
  services.kmscon.hwRender = true;
  services.kmscon.extraConfig = ''
    font-size=14
  '';
  services.kmscon.fonts = [
    {
      name = "Hack Nerd Font Mono";
      package = pkgs.nerdfonts;
    }
  ];

  # Bootloader.
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = lib.mkDefault "1";
      };
      efi = {
        canTouchEfiVariables = true;
        # efiSysMountPoint = "/boot";
      };
    };
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
      experimental-features = nix-command flakes repl-flake
      builders-use-substitutes = true
    '';
  };

  services.power-profiles-daemon.enable = false;
  powerManagement = {
    enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [
      5353
    ];
  };
  services.resolved.enable = true;
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
      workstation = true;
    };
  };
  # networking.nftables.enable = true;
  networking = {
    inherit hostName; # Define your hostname.
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      connectionConfig = {
        "connection.mdns" = 1;
      };
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  # services.localtimed.enable = true;
  # time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.inputMethod = {
    enabled =  "fcitx5";
    # type = "fcitx5";
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

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
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
      nerdfonts
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
    extraGroups = [ "storage" "disk" "libvirtd" "audio" "networkmanager" "sudo" "wheel" "code-server" "input" ];
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      pulseaudio = true;
    };
  };

  # hardware.graphics.enable = true;
  hardware.opengl.enable = true;

  services.usbmuxd.enable = true;

  # Allow unfree packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    coreutils
    socat
    jq
    gparted
    xorg.xhost
    xorg.xrdb
    xsettingsd
    parted
    gnome.adwaita-icon-theme
    qjackctl
    pavucontrol
    helix
    neovim
    linuxKernel.packages."linux_${kernelVersion}".cpupower
    curl
    wget
    wpa_supplicant_gui
    git
    inputs.agenix.packages."${system}".default
    showmethekey
    wev
    libimobiledevice
    ifuse
    nixpkgs_x86.winetricks
    nixpkgs_x86.wineWow64Packages.full
  ] ++ lib.optionals (system == "aarch64-linux") [ nixpkgsUnstable.box64 ];

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
    localuser = null;
    # prunePaths = [ "/media/alex800121" ];
    interval = "hourly";
  };

  qt = {
    enable = true;
    style = "adwaita-dark";
  };

  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

} 
