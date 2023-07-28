# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, userConfig, inputs, system, ... }: let
  # nixpkgsStable = import inputs.nixpkgsStable { inherit system; config.allowUnfree = true; };
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName hostName autoLogin;
  # kernelVersion = "testing";
  kernelVersion = "6_3";
in {
  boot.kernelPackages = pkgs."linuxPackages_${kernelVersion}";

  hardware.enableAllFirmware = true; 
  hardware.enableRedistributableFirmware = true;

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
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
  };

  services.power-profiles-daemon.enable = false;
  # services.cpupower-gui.enable = true;
  powerManagement = {
    enable = true;
  };
  services.tlp = {
    enable = true;
    # enable = false;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      # CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };
  # services.auto-cpufreq.enable = true;
  # services.thermald.enable = true;

  # services.resolved.enable = true;
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    resolveLocalQueries = true;
  };
  networking = {
    inherit hostName; # Define your hostname.
    firewall.enable = false;
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      # dns = "systemd-resolved";
      dns = "dnsmasq";
    };
    # wireless = {
    #   enable = true;
    #   userControlled.enable = true;
    #   networks = {
    #     DaddyAlex = {
    #       pskRaw = "76990429141a7325c5d4448c998cb4db13bd02acc376ef4f0b27299bbff552d1";
    #     };
    #   };
    # };
  };
  # services.connman.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # services.teamviewer.enable = true;

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
    autoLogin.enable = autoLogin;
    autoLogin.user = userName;
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
    enableDefaultFonts = true;
    fonts = with pkgs; [
      nerdfonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      wqy_zenhei
      wqy_microhei
      vistafonts-cht
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK TC" "Ubuntu" ];
        sansSerif = [ "Noto Sans CJK TC" "Ubuntu" ];
        monospace = [ "Noto Sans Mono CJK TC" "Ubuntu" ];
        emoji = ["Noto Color Emoji" ];
      };
    };
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "audio" "networkmanager" "sudo" "wheel" "code-server" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX1Dxv7vWO7viGCaMwdYFk7m468d3ZGiu1jyPTALQuN alex800121@alexrpi4dorm"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGPC8SQm7EwFy2KF1LZlryWjfR/X7xG68LsTMGneU1z alex800121@alexrpi4tp"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf9DW0O5gkq0ephXxUl7SXgb6TMkAA7RgB9NIl4oKNi alex800121@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARVVshQ9ZOtGRPIWensN5uP9nWE3tOI0Ojr6gX5ZaYq ed"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZLAWYLkwEtjlj2e65MwoDOLWUKJBBrjeDf4K0CcuIz alex800121@DaddyAlexAsus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxDNBfYv0w8MLJOLK2nn2kmEpH20G8Y0Mauw9GMHvda alex800121@DaddyAlexAsus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEydwYcKvthPPxPt4P7YkzUgzHahKk/gAMUv7py/jeCN alex800121@acer-nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEelyNLu6y1owoChvv/BfkI4LytFnb7QCyDWPNDAywc alexanderlee800121@cs-458534110940-default"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaDVZZM189JmJc4uiR77DhzqsZ4u5UVtpcH33IR/YW4 alex800121@ipadair"
    ];
  };
  users.users."root" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX1Dxv7vWO7viGCaMwdYFk7m468d3ZGiu1jyPTALQuN alex800121@alexrpi4dorm"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGPC8SQm7EwFy2KF1LZlryWjfR/X7xG68LsTMGneU1z alex800121@alexrpi4tp"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf9DW0O5gkq0ephXxUl7SXgb6TMkAA7RgB9NIl4oKNi alex800121@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARVVshQ9ZOtGRPIWensN5uP9nWE3tOI0Ojr6gX5ZaYq ed"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZLAWYLkwEtjlj2e65MwoDOLWUKJBBrjeDf4K0CcuIz alex800121@DaddyAlexAsus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxDNBfYv0w8MLJOLK2nn2kmEpH20G8Y0Mauw9GMHvda alex800121@DaddyAlexAsus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEydwYcKvthPPxPt4P7YkzUgzHahKk/gAMUv7py/jeCN alex800121@acer-nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEelyNLu6y1owoChvv/BfkI4LytFnb7QCyDWPNDAywc alexanderlee800121@cs-458534110940-default"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
    ];
  };
  security.sudo.wheelNeedsPassword = false; 
   
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
    busybox
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
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg = {
  #   dirmngr.enable = true;
  #   agent = {
  #     enable = true;
  #     enableSSHSupport = true;
  #     enableExtraSocket = true;
  #     enableBrowserSocket = true;
  #     pinentryFlavor = "curses";
  #   };
  # };

  # List services that you want to enable:
  programs.ssh = {
    startAgent = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      UseDns = true;
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      GatewayPorts = "yes";
      # GatewayPorts = "clientspecified";
      X11Forwarding = true;
    };
    extraConfig = ''
      PermitTunnel yes
      PermitTTY yes
      AllowStreamLocalForwarding yes
      AllowTcpForwarding yes
    '';
    allowSFTP = true;
  };

  # Enable the Locate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
    # prunePaths = [ "/media/alex800121" ];
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
