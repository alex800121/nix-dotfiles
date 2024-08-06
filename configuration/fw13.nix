{ ... }: {
  boot.initrd.luks.devices = {
    ENCRYPTED = {
      device = "/dev/disk/by-uuid/aebaf441-09a4-410f-9f23-22858f02ab3f";
      preLVM = true;
    };
  };
}
