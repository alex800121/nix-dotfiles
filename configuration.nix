# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, userName, hostName, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_2;

  hardware.enableAllFirmware = true; 

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };
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
        efiSysMountPoint = "/boot";
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
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
  };

  services.power-profiles-daemon.enable = false;
  powerManagement = {
    enable = true;
  };
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      # CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };
  # services.auto-cpufreq.enable = true;
  # services.thermald.enable = true;

  networking = {
    inherit hostName; # Define your hostname.
    firewall.enable = false;
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      dns = "dnsmasq";
    };
  };
  # services.connman.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.teamviewer.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  time.timeZone = "Asia/Taipei";

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
        # fcitx5-rime
      ];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.wm.keybindings]
      switch-group=['<Super>Above_Tab']
      switch-group-backward=['<Shift><Super>Above_Tab']
    '';
  };
  services.xserver.displayManager = {
    autoLogin.user = userName;
    # hiddenUsers = ["root"];
    gdm = {
      enable = true;
    };
  };

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
  # hardware.pulseaudio = {
  #   package = pkgs.pulseaudioFull;
  #   enable = true;
  # };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    mouse.additionalOptions = "Option \"HighResolutionWheelScrolling\" \"false\"\n";
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_zenhei
      wqy_microhei
      hack-font
      vistafonts-cht
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK TC" "Ubuntu" ];
        sansSerif = [ "Noto Sans CJK TC" "Ubuntu" ];
        monospace = [ "Noto Sans Mono CJK TC" "Ubuntu" ];
      };
    };
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "audio" "networkmanager" "sudo" "wheel" "code-server" ];
  };

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      pulseaudio = true;
    };
  };


  # Allow unfree packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    vim
    curl
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "curses";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      UseDns = true;
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      # PasswordAuthentication = true;
      GatewayPorts = "yes";
    };
    allowSFTP = true;
  };
  # programs.ssh.startAgent = true;

  # Enable the Locate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
    prunePaths = [ "/media/alex800121" ];
    interval = "hourly";
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

  system.stateVersion = "23.05"; # Did you read the comment?
}
