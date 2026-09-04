{ self, inputs, ... }: {
  flake.nixosConfigurations.alexrpi4tprepart = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.alexrpi4tprepart
    ];
  };

  flake.nixosConfigurations.alexrpi4tp = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.alexrpi4tp
      _hardware/alexrpi4tp.nix
    ];
  };

  flake.nixosModules.alexrpi4tprepart =
    {
      modulesPath,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) efiArch;
    in
    {
      imports = [
        "${modulesPath}/image/repart.nix"
        "${modulesPath}/profiles/minimal.nix"
        self.nixosModules.minimal
        self.nixosModules.topo
        self.nixosModules.distributed-builds
        self.nixosModules.tailscale-server
      ];

      boot.initrd.systemd.repart.enable = true;
      boot.initrd.systemd.enable = true;

      systemd.repart.partitions."10-root" = {
        Type = "root";
        GrowFileSystem = "yes";
      };

      image.repart = {
        name = "alexrpi4tp";
        partitions = {
          "10-esp" = {
            contents = {
              "/".source = inputs.rpi4fw.outPath;
              "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
                "${config.systemd.package}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

              "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
                "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
            };
            repartConfig = {
              Format = "vfat";
              Label = "ESP";
              SizeMinBytes = "1G";
              Type = "esp";
            };
          };
          root = {
            storePaths = [ config.system.build.toplevel ];
            nixStorePrefix = "/nix/store";
            repartConfig = {
              Format = "btrfs";
              Label = "NIXOS";
              Type = "root";
              Subvolumes = "/root /home /nix /swap";
              MakeDirectories = "/root /home /nix /swap /root/boot /root/nix /root/swap /root/home /nix/store";
              Minimize = "guess";
            };
          };
        };
      };

      systemd.services."create-swapfile" = {
        description = "Create Btrfs swapfile";
        unitConfig = {
          DefaultDependencies = false;
          ConditionPathExists = "!/swap/swapfile";
        };
        requiresMountsFor = [ "/swap" ];
        before = [ "swap-swapfile.swap" ];
        requiredBy = [ "swap-swapfile.swap" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.btrfs-progs}/bin/btrfs filesystem mkswapfile --size 8g --uuid clear /swap/swapfile";
        };
      };

      swapDevices = [ { device = "/swap/swapfile"; } ];

      # Because no generation is built at the first boot and the clock is updated during the first boot,
      # gc is triggered and cleans out essential binaries, locking out user.
      # Need to disable gc to prevent it from happening.
      nix.gc.automatic = false;
      nix.optimise.automatic = false;

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "vc4"
        "pcie_brcmstb" # required for the pcie bus to work
        "reset-raspberrypi" # required for vl805 firmware to load
      ];

      initConfig.defaultUser = "alex800121";
      initConfig.hostName = "alexrpi4tp";

      fileSystems."/".neededForBoot = true;
      fileSystems."/boot".neededForBoot = true;

      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      boot.loader.grub.enable = false;
      boot.loader.systemd-boot.enable = true;
      boot.loader.generic-extlinux-compatible.enable = false;
      boot.loader.efi.canTouchEfiVariables = false;

      fileSystems."/" = {
        device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
        fsType = "btrfs";
        options = [
          "noatime"
          "compress=zstd"
          "subvol=root"
        ];
      };

      fileSystems."/home" = {
        device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
        fsType = "btrfs";
        options = [
          "noatime"
          "compress=zstd"
          "subvol=home"
        ];
      };

      fileSystems."/nix" = {
        device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
        fsType = "btrfs";
        options = [
          "noatime"
          "compress=zstd"
          "subvol=nix"
        ];
      };

      fileSystems."/swap" = {
        device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
        fsType = "btrfs";
        options = [
          "noatime"
          "subvol=swap"
        ];
      };

      fileSystems."/boot" = {
        device = lib.mkForce "/dev/disk/by-partlabel/ESP";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };

      powerManagement.enable = false;

      boot.kernelParams = [ "net.ifnames=0" ];
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."10-eth0" = {
        matchConfig = {
          Name = "eth0";
        };
        networkConfig = {
          DHCP = true;
          MulticastDNS = true;
          LLMNR = true;
        };
        linkConfig = {
          Multicast = true;
          AllMulticast = true;
        };
      };

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };

  flake.nixosModules.alexrpi4tp =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.common
        self.nixosModules.ssh-serve
        self.nixosModules.topo
        self.nixosModules.distributed-builds
        self.nixosModules.tailscale-server
        # self.nixosModules.nix-ld
        self.nixosModules.vaultwarden
        self.nixosModules.borgbackup-vaultwarden
        inputs.agenix.nixosModules.default
      ];

      nixpkgs.overlays = [
        self.overlays.neovim-min
      ];

      services.vaultwarden.borgbackup.enable = true;
      services.vaultwarden.borgbackup.servers = [ "acer-tp" ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.generic-extlinux-compatible.enable = false;
      boot.loader.efi.canTouchEfiVariables = false;

      boot.initrd.supportedFilesystems.btrfs = true;

      boot.supportedFilesystems.btrfs = true;

      fileSystems."/".device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
      fileSystems."/".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/home".device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
      fileSystems."/home".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/nix".device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
      fileSystems."/nix".options = [
        "noatime"
        "compress=zstd"
      ];

      fileSystems."/swap".device = lib.mkForce "/dev/disk/by-partlabel/NIXOS";
      fileSystems."/swap".options = [ "noatime" ];

      fileSystems."/boot".device = lib.mkForce "/dev/disk/by-partlabel/ESP";
      fileSystems."/boot".neededForBoot = true;

      swapDevices = [ { device = "/swap/swapfile"; } ];

      documentation.man.enable = true;
      documentation.man.cache.enable = true;
      documentation.man.cache.generateAtRuntime = true;

      networking.networkmanager.enable = false;
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "vc4"
        "pcie_brcmstb" # required for the pcie bus to work
        "reset-raspberrypi" # required for vl805 firmware to load
      ];

      initConfig.defaultUser = "alex800121";
      initConfig.hostName = "alexrpi4tp";

      fileSystems."/".neededForBoot = true;

      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      # Enables the generation of /boot/extlinux/extlinux.conf
      # boot.loader.generic-extlinux-compatible.enable = true;
      boot.loader.grub.enable = false;

      powerManagement.enable = false;

      boot.kernelParams = [ "net.ifnames=0" ];
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."10-eth0" = {
        matchConfig = {
          Name = "eth0";
        };
        networkConfig = {
          DHCP = true;
          MulticastDNS = true;
          LLMNR = true;
        };
        linkConfig = {
          Multicast = true;
          AllMulticast = true;
        };
      };

      # List packages installed in system profile. To search, run:
      environment.systemPackages = with pkgs; [
        raspberrypi-eeprom
        libraspberrypi
        raspberrypifw
        device-tree_rpi
      ];

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      programs.mtr.enable = true;
    };
}
