{ self, inputs, ... }: {
  flake.nixosConfigurations.alexrpi4tpmin = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.alexrpi4tpmin
    ];
  };

  flake.nixosConfigurations.alexrpi4tp = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.alexrpi4tp
    ];
  };

  flake.nixosModules.alexrpi4tpmin =
    {
      modulesPath,
      config,
      lib,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix")
        self.nixosModules.rpi4
        _hardware/rpi4.nix
      ];

      sdImage.compressImage = false;
      sdImage.expandOnBoot = true;
      users.users.root.initialPassword = "root";
      users.users."${config.initConfig.defaultUser}".initialPassword =
        lib.mkForce "${config.initConfig.defaultUser}";
      nixpkgs.overlays = [
        (final: super: {
          makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
      services.openssh.settings.PermitRootLogin = "yes";
      networking.wireless.iwd.enable = lib.mkForce true;
      networking.wireless.enable = lib.mkForce false;
    };

  flake.nixosModules.alexrpi4tp =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.rpi4
        self.nixosModules.topo
        self.nixosModules.distributed-builds
        self.nixosModules.ssh-serve
        _hardware/alexrpi4tp.nix
        self.nixosModules.tailscale-server
        self.nixosModules.nix-ld
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

      fileSystems."/".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/home".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/nix".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/swap".options = [ "noatime" ];
      fileSystems."/boot".neededForBoot = true;
      swapDevices = [ { device = "/swap/swapfile"; } ];

      documentation.man.enable = true;
      documentation.man.cache.enable = true;
      documentation.man.cache.generateAtRuntime = true;

      networking.networkmanager.enable = false;
    };

  flake.nixosModules.rpi4 =
    {
      lib,
      conf,
      pkgs,
      ...
    }:
    {

      imports = [
        self.nixosModules.common
      ];

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

      # hardware.deviceTree.enable = true;
      # hardware.deviceTree.filter = "bcm2711-rpi-4-b.dtb";
      # hardware.deviceTree.name = "broadcom/bcm2711-rpi-4-b.dtb";
      # hardware.deviceTree.overlays = [
      #   {
      #     name = "gpio-fan";
      #     dtsText = ''
      #       /dts-v1/;
      #       /plugin/;
      #
      #       / {
      #               compatible = "brcm,bcm2711";
      #
      #               fragment@0 {
      #                       target-path = "/";
      #                       __overlay__ {
      #                               fan0: gpio-fan@0 {
      #                                       compatible = "gpio-fan";
      #                                       gpios = <&gpio 14 0>;
      #                                       gpio-fan,speed-map = <0    0>,
      #                                                                                <5000 1>;
      #                                       #cooling-cells = <2>;
      #                               };
      #                       };
      #               };
      #
      #               fragment@1 {
      #                       target = <&cpu_thermal>;
      #                       polling-delay = <2000>;	/* milliseconds */
      #                       __overlay__ {
      #                               trips {
      #                                       cpu_hot: trip-point@0 {
      #                                               temperature = <55000>;	/* (millicelsius) Fan started at 65°C */
      #                                               hysteresis = <10000>;	/* (millicelsius) Fan stopped at 55°C */
      #                                               type = "active";
      #                                       };
      #                               };
      #                               cooling-maps {
      #                                       map0 {
      #                                               trip = <&cpu_hot>;
      #                                               cooling-device = <&fan0 1 1>;
      #                                       };
      #                               };
      #                       };
      #               };
      #               __overrides__ {
      #                       gpiopin = <&fan0>,"gpios:4", <&fan0>,"brcm,pins:0";
      #                       temp = <&cpu_hot>,"temperature:0";
      #               };
      #       };
      #     '';
      #   }
      # ];

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
