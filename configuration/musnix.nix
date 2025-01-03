{ inputs, userConfig, lib, ... }: {

  system.nixos.tags = ["musnix"];
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  musnix.enable = true;
  musnix.soundcardPciId = userConfig.soundcardPciId;
  powerManagement.cpuFreqGovernor = lib.mkForce null;
  musnix.das_watchdog.enable = true;
  musnix.rtirq.enable = true;
}
