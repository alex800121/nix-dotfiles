# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  boot.kernelPackages = pkgs.linuxPackages_testing;
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
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        devices = [ "nodev" ];
        efiSupport = true;
        enable = true;
        version = 2;
        useOSProber = true;
        fontSize = 40;
      };
    };
  };

  # fileSystems."/media/alex800121/Asus" = {
  #   device = "/dev/disk/by-uuid/F2D200EBD200B63F";
  #   fsType = "ntfs";
  #   options = [ "rw" "uid=1000" ];
  # };

  nix = {
    package = pkgs.nix; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.overlays = [ (self: super: {
    auto-cpufreq = super.auto-cpufreq.overridePythonAttrs(old: rec{
      patches = old.patches ++ [
        ./patches/detect_charging.patch
      ];
    } );
  } ) ];

  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  time.timeZone = "Asia/Taipei";

  programs.bash = {
    enableCompletion = true;
    enableLsColors = true;
  };


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
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
  # Enable bluetooth
  hardware.bluetooth.enable = true;
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
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_zenhei
      wqy_microhei
      hack-font
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
    extraGroups = [ "sudo" "networkmanager" "wheel" ];
  };

  home-manager = {
    users.alex800121 = import ./home.nix { inherit config pkgs; }; 
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the Locate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
