{ nixpkgsUnstable, pkgs, ... }: {

  imports = [
    ./common.nix
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "vc4"
    "pcie_brcmstb" # required for the pcie bus to work
    "reset-raspberrypi" # required for vl805 firmware to load
  ];
  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/".neededForBoot = true;
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  fileSystems."/boot".neededForBoot = true;
  swapDevices = [{ device = "/swap/swapfile"; }];

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.grub.enable = false;

  hardware.deviceTree.enable = true;
  hardware.deviceTree.filter = "bcm2711-rpi-4-b.dtb";
  hardware.deviceTree.name = "broadcom/bcm2711-rpi-4-b.dtb";
  hardware.deviceTree.overlays = [
    {
      name = "gpio-fan";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
                compatible = "brcm,bcm2711";

                fragment@0 {
                        target-path = "/";
                        __overlay__ {
                                fan0: gpio-fan@0 {
                                        compatible = "gpio-fan";
                                        gpios = <&gpio 14 0>;
                                        gpio-fan,speed-map = <0    0>,
                                                                                 <5000 1>;
                                        #cooling-cells = <2>;
                                };
                        };
                };

                fragment@1 {
                        target = <&cpu_thermal>;
                        polling-delay = <2000>;	/* milliseconds */
                        __overlay__ {
                                trips {
                                        cpu_hot: trip-point@0 {
                                                temperature = <65000>;	/* (millicelsius) Fan started at 55°C */
                                                hysteresis = <10000>;	/* (millicelsius) Fan stopped at 45°C */
                                                type = "active";
                                        };
                                };
                                cooling-maps {
                                        map0 {
                                                trip = <&cpu_hot>;
                                                cooling-device = <&fan0 1 1>;
                                        };
                                };
                        };
                };
                __overrides__ {
                        gpiopin = <&fan0>,"gpios:4", <&fan0>,"brcm,pins:0";
                        temp = <&cpu_hot>,"temperature:0";
                };
        };
      '';
    }
  ];

  powerManagement.enable = false;

  networking.networkmanager.enable = false;

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


  documentation.man.generateCaches = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    nixpkgsUnstable.raspberrypi-eeprom
    libraspberrypi
    raspberrypifw
    device-tree_rpi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

}

