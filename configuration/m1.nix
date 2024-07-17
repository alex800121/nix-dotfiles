{ inputs, ... }: {
  hardware.asahi.setupAsahiSound = true;
  hardware.asahi.peripheralFirmwareDirectory = inputs.apple-firmware;
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.experimentalGPUInstallMode = "overlay";
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];
  nix.settings.cores = 4;
  nix.settings.max-jobs = 4;
}
