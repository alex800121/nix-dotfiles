{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    ./initConfig.nix
    ../programs/kmscon
    ../programs/bash
  ];

  config = lib.mkMerge [
    (lib.mkIf (config.initConfig.defaultUser != null) {
      users.users."${config.initConfig.defaultUser}" = {
        isNormalUser = true;
        description = "${config.initConfig.defaultUser}";
        extraGroups = [
          "networkmanager"
          "tss"
          "storage"
          "disk"
          "libvirtd"
          "audio"
          "systemd-network"
          "sudo"
          "wheel"
          "code-server"
          "input"
        ];
        uid = 1000;
        initialPassword = "";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaDVZZM189JmJc4uiR77DhzqsZ4u5UVtpcH33IR/YW4 alex800121@ipadair"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG885XYlPfi2h6hiokfhvZgHF1y2f3JnL11j+ARJkrXE alex800121@fw13"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKH5JQY6WjU7N0Z+WYoHiej4TzhN8Prfs5uiqvXExPvm root@fw13"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYRhvHSun0BXMV1oBi93FncWVFEma5pv6fKeruccOuW alex800121@acer-tp"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpxrX0RcNtg/wOxeJ7SUkUEVzWUYvZk4z0Khd7fxgVd root@acer-tp"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+ alex800121@alexrpi4tp"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCwYhT26ZCYB0fSe9rAyvQdV9sz/me2V+vL9dLVWd0W root@alexrpi4tp"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv15uz9Ndk+y0SZ2L64OgjLXBV8JwTDHbYca9a/oYHx alex800121@oracle"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHudmbpZMo5vJ4m2WxV3dyw9BTapuoN6AdTnfZuugo99 root@oracle"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn3nkUDVHY0ZDAxo6bAjMb2k5ic7G6RCDQkBOtJo8dd alex800121@oracle2"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYAa4EReVbKim6EeXqwlFB88zmajL31WWfVsvIOO1Lc root@oracle2"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGobHzAuouhLf9IXr9eJl2saxFkal+cxcTAWP8EYo+Zl alex800121@oracle3"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVrCm9KX83d8Uv46MZ8aYm7frR9zuQwuK9opRB9/HZt root@oracle3"
        ];
      };
    })
    ({

      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;

      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];

      programs.ssh = {
        startAgent = lib.mkDefault true;
        forwardX11 = false;
      };

      # Enable the OpenSSH daemon.
      services.openssh = {
        enable = true;
        ports = [ 22 ];
        # ports = [ 22000 ];
        settings = {
          UseDns = true;
          PermitRootLogin = lib.mkDefault "prohibit-password";
          PasswordAuthentication = false;
          # GatewayPorts = "yes";
          GatewayPorts = "clientspecified";
          X11Forwarding = false;
        };
        extraConfig = ''
          PermitTunnel yes
          PermitTTY yes
          AllowStreamLocalForwarding yes
          AllowTcpForwarding yes
          UsePAM no
        '';
        allowSFTP = true;
        openFirewall = true;
      };

      console = {
        earlySetup = true;
        font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
      };

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.builders-use-substitutes = true;
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
      users.groups.users.gid = 100;
      security.sudo.wheelNeedsPassword = false;

      environment.etc.inputrc = {
        enable = true;
        source = ./inputrc;
      };

      environment.systemPackages = with pkgs; [
        nix-prefetch-git
        dmidecode
        fastfetch
        zellij
        coreutils
        parted
        inputs.agenix.packages.${system}.default
        ripgrep
        neovim
        curl
        wget
        btrfs-progs
        wl-clipboard
        jq
        lemonade
        btop
        chawan
      ];

      environment.etc."zellij/config.kdl" = {
        enable = true;
        source = ../programs/zellij/config.kdl;
      };
      environment.variables.ZELLIJ_CONFIG_DIR = "/etc/zellij";

      programs.git.enable = true;

      environment.variables.EDITOR = "nvim";
      environment.variables.VISUAL = "nvim";
      environment.variables.SUDO_EDITOR = "nvim";

      networking.wireless.iwd.enable = true;

      system.stateVersion = lib.mkDefault "26.05";
    })
  ];
}
