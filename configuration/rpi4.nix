# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, userConfig, inputs, kernelVersion, ... }: let
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
  programs.ssh.startAgent = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
    extraGroups = [ "storage" "disk" "libvirtd" "audio" "networkmanager" "sudo" "wheel" "code-server" "input" ];
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/FOfzUF0nSno+780hSUGX1bDPqmfZpEUG0f/imEl3r alex800121@alexrpi4dorm"
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
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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
  system.stateVersion = "24.05"; # Did you read the comment?

}
