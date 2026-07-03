{ inputs, lib, ... }:
{

  system.nixos.tags = [ "musnix" ];
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  musnix.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkForce null;
  musnix.das_watchdog.enable = true;
  musnix.rtirq.enable = true;
}
