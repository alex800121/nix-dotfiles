{ ... }: {
  boot.initrd.luks.devices = {
    ENCRYPTED = {
      device = "";
      preLVM = true;
      allowDiscards = true;
      bypassWorkqueues = true;
    };
  };
}
