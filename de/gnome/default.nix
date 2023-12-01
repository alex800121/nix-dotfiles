{ lib, userConfig, inputs, pkgs, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable {
    inherit (pkgs) system;
    allowUnfree = true;
  };
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName autoLogin;
in {
  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.wm.keybindings]
      switch-group=['<Super>Above_Tab']
      switch-group-backward=['<Shift><Super>Above_Tab']
    '';
  };
  services.xserver.displayManager = {
    autoLogin.enable = autoLogin;
    autoLogin.user = userName;
    # lightdm = {
    #   enable = true;
    # };
    gdm = {
      enable = true;
    };
    # sddm = {
    #   enable = true;
    #   enableHidpi = true;
    # };
  };
  services.gnome.gnome-settings-daemon.enable = true;
  environment.systemPackages = [
    pkgs.gnomeExtensions.kimpanel
  ];
}
