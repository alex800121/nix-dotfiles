{ lib, userConfig, config, pkgs, inputs, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable {
    inherit (pkgs) system;
    allowUnfree = true;
  };
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName autoLogin;
  hyprlandUnstable = nixpkgsUnstable.hyprland.override {
    enableXWayland = config.programs.hyprland.xwayland.enable;
    hidpiXWayland = config.programs.hyprland.xwayland.hidpi;
  };
in {
  home-manager.users.alex800121.xdg.configFile."networkmanager-dmenu".source = ./networkmanager-dmenu;
  home-manager.users.alex800121.xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Gdk/UnscaledDPI 98304
    Gdk/WindowScalingFactor 2
  '';
  home-manager.users.alex800121.services.mako = {
    enable = true;
    package = nixpkgsUnstable.mako;
    actions = true;
    anchor = "top-right";
    defaultTimeout = 5000;
    icons = true;
    ignoreTimeout = false;
    layer = "top";
  };

  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    settings = {
      X11 = {
        ServerArguments = "-dpi 192";
      };
    };
  };

  programs.hyprland.enable = true;
  programs.hyprland.package = hyprlandUnstable;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.xwayland.hidpi = true;

  xdg.portal.xdgOpenUsePortal = true;

  environment.systemPackages = [
    # swaynotificationcenter
    # nixpkgsUnstable.mako
    nixpkgsUnstable.hyprpaper
    nixpkgsUnstable.hyprpicker
    nixpkgsUnstable.gnome.nautilus
    (nixpkgsUnstable.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true "]; }))
    pkgs.wofi
    pkgs.networkmanagerapplet
    nixpkgsUnstable.networkmanager_dmenu
    pkgs.brightnessctl
    pkgs.swaylock
    pkgs.swayidle
    pkgs.socat
    (import ./wofi-power { inherit pkgs; hyprland = hyprlandUnstable; })
  ];

  security.pam.services.swaylock.text = ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    
    auth include login
  '';
  
  environment.variables = {
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    NIXOS_OZONE_WL = "1";
  };
}
