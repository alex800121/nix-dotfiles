{ ... }: {
  # boot.initrd.luks.devices = {
  #   ENCRYPTED = {
  #     device = "";
  #     preLVM = true;
  #     allowDiscards = true;
  #     bypassWorkqueues = true;
  #   };
  # };

  boot.initrd.systemd.enable = true;

  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    hostKeys = /etc/ssh/ssh_initrd_host_ed25519_key;
    authorizedKeys = ''
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMraRiOlQzoow7HBhsDh+HQKrh5tddB1wB8MIMaw0kf alex800121@fw13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiEjgHDmxvOFNprdiea9uvUvWMxC1Wub/JSO7dqZMwF root@fw13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM alex800121@alexrpi4tp"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICF22WQW3bhm7MpPR9Ye3SFDudNJ6XdXgEqSIrE7Cv33 root@alexrpi4tp"
    '';
  };

  boot.initrd.availableKernelModules = [
    "r8152"
    "xhci_hcd"
  ];
}
