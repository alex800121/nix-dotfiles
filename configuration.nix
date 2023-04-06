# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # <home-manager/nixos>
    ];

  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_6_2;
  # boot.kernelPatches = [
  #   {
  #     name = "keyboard";
  #     patch = ./patches/keyboard.patch;
  #   }
  # ];

  hardware.enableAllFirmware = true; 

  # Bootloader.
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      # grub = {
      #   devices = [ "nodev" ];
      #   efiSupport = true;
      #   enable = true;
      #   version = 2;
      #   useOSProber = true;
      #   fontSize = 40;
      # };
    };
  };

  fileSystems = {
    "/media/alex800121/Asus" = {
      device = "/dev/disk/by-uuid/AC6E34966E345B72";
      fsType = "ntfs";
      options = [ "rw" "uid=1000" ];
    };
    "/home/alex800121/OneDrive" = {
      device = "/media/alex800121/Asus/Users/alex800121/OneDrive/";
      options = [ "bind" ];
    };
  };

  nix = {
    # package = pkgs.nix; # or versioned attributes like nixVersions.nix_2_8
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
    hostName = "asus-nixos"; # Define your hostname.
    # useDHCP = true;
    firewall.enable = false;
    networkmanager = {
      # enable = false;
      enable = true;
      dhcp = "dhcpcd";
      dns = "dnsmasq";
      # wifi.backend = "iwd";
    };
    # wireless = {
    #   enable = true;
    #   userControlled.enable = true;
    # };

  };
  # services.connman.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  time.timeZone = "Asia/Taipei";

  # programs.bash = {
  #   enableCompletion = true;
  #   enableLsColors = true;
  # };

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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.wm.keybindings]
      switch-group=['<Super>Above_Tab']
      switch-group-backward=['<Shift><Super>Above_Tab']
    '';
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
    # wireplumber.enable = false;
    # media-session.enable = true;
    # media-session.config.bluez-monitor = {
    #   properties = {
    #     "bluez5.codecs" = [ "sbc" "aac" "ldac" "aptx" "aptx_hd" ];
    #     "bluez5.mdbc-support" = true;
    #   };
    #   # rules = [
    #   #   {
    #   #     actions = {
    #   #       update-props = {
    #   #         "bluez5.auto-connect" = [ "hsp_hs" "hfp_hf" "a2dp_sink" ];
    #   #         "bluez5.hw-volume" =
    #   #           [ "hsp_ag" "hfp_ag" "a2dp_source" "a2dp_sink" ];
    #   #         "bluez5.autoswitch-profile" = false;
    #   #       };
    #   #     };
    #   #     matches = [{ "device.name" = "~bluez_card.*"; }];
    #   #   }
    #   #   {
    #   #     actions = { update-props = { "node.pause-on-idle" = false; }; };
    #   #     matches = [
    #   #       { "node.name" = "~bluez_input.*"; }
    #   #       { "node.name" = "~bluez_output.*"; }
    #   #     ];
    #   #   }
    #   # ];
    # };
  };
  
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   jack.enable = true;
  # };

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
  users.users.alex800121 = {
    isNormalUser = true;
    description = "alex800121";
    # extraGroups = [ "sudo" "networkmanager" "wheel" ];
    extraGroups = [ "audio" "networkmanager" "sudo" "wheel" "code-server" ];
  };

  # home-manager = {
  #   users.alex800121 = import ./home.nix { inherit config pkgs lib; }; 
  # };

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      pulseaudio = true;
    };
  };
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
  services.openssh.enable = true;
  # programs.ssh.startAgent = true;

  # Enable the Locate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
    prunePaths = [ "/media/alex800121" ];
    interval = "hourly";
  };

  # services.spotifyd.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
