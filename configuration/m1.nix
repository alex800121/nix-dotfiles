{ inputs, ... }: {
  hardware.asahi.peripheralFirmwareDirectory = inputs.apple-firmware;
  hardware.asahi.useExperimentalGPUDriver = true;
  # hardware.asahi.experimentalGPUInstallMode = "overlay";
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];
}
