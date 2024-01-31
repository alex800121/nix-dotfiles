# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, lib, userConfig, inputs, kernelVersion, ... }:
let
  nixpkgsUnstable = import inputs.nixpkgsUnstable { inherit system; config.allowUnfree = true; };
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName hostName;
  inherit (pkgs) system;
in
{
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
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
        consoleMode = "1";
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
    '';
    settings.trusted-users = [ "@wheel" ];
  };

  services.power-profiles-daemon.enable = false;
  powerManagement = {
    enable = true;
  };

  services.tlp = {
    enable = true;
    # enable = false;
    settings = {
      NMI_WATCHDOG = 0;
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      # START_CHARGE_THRESH_BAT1 = 75;
      # STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };

  services.resolved.enable = true;
  networking = {
    inherit hostName; # Define your hostname.
    firewall.enable = false;
    networkmanager = {
      enable = true;
      # dhcp = "dhcpcd";
      dns = "systemd-resolved";
      # dns = "dnsmasq";
      # dns = "default";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  # services.localtimed.enable = true;
  # time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      # enableRimeData = true;
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
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
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

  hardware.opengl.enable = true;

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
  ];

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

  # services.teamviewer.enable = true;

  qt = {
    enable = true;
    style = "adwaita-dark";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # services.code-server = {
  #   enable = true;
  #   port = 4444;
  #   user = "alex800121";
  #   host = "127.0.0.1";
  #   auth = "password";
  #   # printf "password" | sha256sum | cut -d' ' -f1
  #   hashedPassword = "58cb754c8c077d146dc4a5651ef3cbc79ccfd99c4ad37244ef0ccc3e8470365c";
  #   extraArguments = [
  #     "--verbose"
  #   ];
  # };

  system.stateVersion = "23.11"; # Did you read the comment?
}
