# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, userConfig, inputs, kernelVersion, config, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable { inherit system; config.allowUnfree = true; };
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName hostName;
  inherit (pkgs) system;
in {

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  boot.kernelPackages = pkgs."linuxPackages_${kernelVersion}";

  hardware.enableAllFirmware = true; 
  hardware.enableRedistributableFirmware = true;
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  hardware.raspberry-pi."4" = {
    apply-overlays-dtmerge.enable = true; 
    fkms-3d.enable = true; 
    pwm0.enable = true; 
  };
  hardware.deviceTree.overlays = [
    {
      name = "gpio-fan";
      dtsText = ''
        /dts-v1/;

        / {
                compatible = "brcm,bcm2711";

                fragment@0 {
                        target-path = "/";

                        __overlay__ {

                                gpio-fan@0 {
                                        compatible = "gpio-fan";
                                        gpios = <0xffffffff 0x0c 0x00>;
                                        gpio-fan,speed-map = <0x00 0x00 0x1388 0x01>;
                                        #cooling-cells = <0x02>;
                                        phandle = <0x02>;
                                };
                        };
                };

                fragment@1 {
                        target = <0xffffffff>;

                        __overlay__ {
                                polling-delay = <0x7d0>;
                        };
                };

                fragment@2 {
                        target = <0xffffffff>;

                        __overlay__ {

                                trip-point@0 {
                                        temperature = <0xd6d8>;
                                        hysteresis = <0x2710>;
                                        type = "active";
                                        phandle = <0x01>;
                                };
                        };
                };

                fragment@3 {
                        target = <0xffffffff>;

                        __overlay__ {

                                map0 {
                                        trip = <0x01>;
                                        cooling-device = <0x02 0x01 0x01>;
                                };
                        };
                };

                __overrides__ {
                        gpiopin = <0x02 0x6770696f 0x733a3400 0x02 0x6272636d 0x2c70696e 0x733a3000>;
                        temp = [00 00 00 01 74 65 6d 70 65 72 61 74 75 72 65 3a 30 00];
                        hyst = [00 00 00 01 68 79 73 74 65 72 65 73 69 73 3a 30 00];
                };

                __symbols__ {
                        fan0 = "/fragment@0/__overlay__/gpio-fan@0";
                        cpu_hot = "/fragment@2/__overlay__/trip-point@0";
                };

                __fixups__ {
                        gpio = "/fragment@0/__overlay__/gpio-fan@0:gpios:0";
                        cpu_thermal = "/fragment@1:target:0";
                        thermal_trips = "/fragment@2:target:0";
                        cooling_maps = "/fragment@3:target:0";
                };

                __local_fixups__ {

                        fragment@3 {

                                __overlay__ {

                                        map0 {
                                                trip = <0x00>;
                                                cooling-device = <0x00>;
                                        };
                                };
                        };

                        __overrides__ {
                                gpiopin = <0x00 0x0c>;
                                temp = <0x00>;
                                hyst = <0x00>;
                        };
                };
        };
      '';
    }
  ];

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
  };
  networking = {
    inherit hostName; # Define your hostname.
    firewall.enable = false;
    networkmanager = {
      enable = true;
      # dhcp = "dhcpcd";
      # dns = "systemd-resolved";
      # dns = "dnsmasq";
      # dns = "default";
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    neovim
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    coreutils
    inputs.agenix.packages."${system}".default
    raspberrypi-eeprom
    libraspberrypi
    raspberrypifw
    device-tree_rpi
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

