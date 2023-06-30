{ lib, userConfig, config, pkgs, inputs, system, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable {
    inherit system;
    allowUnfree = true;
  };
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName autoLogin;
in {
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
  programs.hyprland.enable = true;
  programs.hyprland.package = nixpkgsUnstable.hyprland.override {
    enableXWayland = config.programs.hyprland.xwayland.enable;
    hidpiXWayland = config.programs.hyprland.xwayland.hidpi;
  };
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.xwayland.hidpi = true;
  environment.systemPackages = [
    # swaynotificationcenter
    nixpkgsUnstable.mako
    nixpkgsUnstable.hyprpaper
    nixpkgsUnstable.hyprpicker
    (nixpkgsUnstable.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true "]; }))
    pkgs.wofi
    pkgs.networkmanagerapplet
  ];
}
