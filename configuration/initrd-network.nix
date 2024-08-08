{config, userConfig, ...}: {
  boot.initrd.systemd = {
    enable = true;
    enableTpm2 = true;
  };

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      hostKeys = [ /etc/secrets/initrd_ssh_host_ed25519_key ];
      authorizedKeys = config.users.users."${userConfig.userName}".openssh.authorizedKeys.keys;
      port = 2222;
    };
  };

  boot.kernelParams = [
    "ip=dhcp"
  ];
  boot.initrd.availableKernelModules = [
    "mt7921e"
    "iwlwifi"
    "r8152"
    "xhci_hcd"
    "xhci_pci"
  ];
}
