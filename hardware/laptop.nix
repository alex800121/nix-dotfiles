{ config, lib, pkgs, inputs, ... }: {
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "suspend";
    killUserProcesses = false;
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
  };
  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
}
