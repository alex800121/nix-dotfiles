{ config, lib, pkgs, inputs, ... }: {
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
    KillUserProcesses = false;
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };
  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
}
