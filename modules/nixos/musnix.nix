{ inputs, ... }:
{
  flake.nixosModules.musnix =
    {
      lib,
      pkgs,
      ...
    }:
    {
      system.nixos.tags = [
        "rt"
        "musnix"
      ];

      imports = [
        inputs.musnix.nixosModules.musnix
      ];

      environment.systemPackages = [
        pkgs.real_time_config_quick_scan
      ];

      musnix.enable = true;
      musnix.kernel.realtime = true;
      powerManagement.cpuFreqGovernor = lib.mkForce null;
      musnix.das_watchdog.enable = true;
      musnix.rtirq.enable = true;
    };
}
