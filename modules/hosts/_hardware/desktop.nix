{ config, lib, pkgs, modulesPath, ... }:
{
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    KillUserProcesses = false;
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
    IdleAction = "ignore";
  };
}
