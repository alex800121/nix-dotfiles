{ config, userConfig, lib, ... }: {

  boot.initrd.systemd.enable = true;

  boot.initrd.network.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.services.resolved.enable = true;

  boot.kernelParams = [
    "ip=dhcp"
  ];

  boot.initrd.availableKernelModules = [
    "tpm"
    "mt7921e"
    "iwlwifi"
    "r8152"
    "xhci_hcd"
    "xhci_pci"
  ];

}
