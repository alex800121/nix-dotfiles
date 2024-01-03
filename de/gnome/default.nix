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
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          # "org/gnome/mutter".experimental-features = ["scale-monitor-framebuffer"];
          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
            disable-while-typing = true;
            natural-scroll = true;
            speed = 0.19999999999999996;
            two-finger-scrolling-enabled = true;
          };
          "org/gnome/desktop/peripherals/mouse" = {
            natural-scroll = false;
            speed=0.24778761061946897;
          };
          "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
          "org/gnome/desktop/wm/keybindings" = {
            switch-group= [ "<Super>Above_Tab"];
            switch-group-backward=["<Shift><Super>Above_Tab"];
            toggle-fullscreen=["<Super>f"];
          };
          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>t";
            command = "alacritty";
            name = "Terminal";
          };
          "org/gnome/desktop/default-applications/terminal" = {
            exec = "alacritty";
            exec-arg = "";
          };
          "org/gnome/shell".favorite-apps = [
            "firefox.desktop"
            "spotify.desktop"
            "code.desktop"
            "Alacritty.desktop"
            "org.gnome.Nautilus.desktop"
            "writer.desktop"
          ];
          "org/gnome/desktop/background" = {
            color-shading-type = "solid";
            picture-options = "none";
            primary-color = "#000000";
            secondary-color = "#f0f0f0";
          };
        };
      }
    ];
  };
  services.gnome.gnome-settings-daemon.enable = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.kimpanel
    gnomeExtensions.appindicator
  ];
}
