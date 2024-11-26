{ lib, userConfig, pkgs, ... }:
let
  defaultConfig = {
    autoLogin = false;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName autoLogin;
in
{

  services.xserver.displayManager = {
    gdm = {
      wayland = true;
      enable = true;
    };
  };

  services.displayManager = {
    autoLogin.enable = autoLogin;
    autoLogin.user = userName;
    defaultSession = "gnome";
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.default-applications.terminal]
      exec='alacritty'
      exec-arg='-e'
    '';
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [ "scale-monitor-framebuffer" ];
            dynamic-workspaces = true;
          };

          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
              "kimpanel@kde.org"
              "drive-menu@gnome-shell-extensions.gcampax.github.com"
              "auto-power-profile@dmy3k.github.io"
              "gtk4-ding@smedius.gitlab.com"
            ];
            welcome-dialog-last-shown-version = "47.0";
          };
          "org/gnome/shell/extensions/gtk4-ding" = {
            show-network-volumes = true;
          };

          "org/gnome/shell/extensions/kimpanel".vertical = true;

          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
            disable-while-typing = true;
            natural-scroll = true;
            speed = 0.19999999999999996;
            two-finger-scrolling-enabled = true;
          };

          "org/gnome/desktop/peripherals/mouse" = {
            natural-scroll = false;
            speed = 0.24778761061946897;
          };

          "org/gnome/settings-daemon/plugins/power" = {
            ambient-enabled = true;
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-ac-timeout = lib.gvariant.mkInt32 900;
            sleep-inactive-battery-type = "suspend";
            sleep-inactive-battery-timeout = lib.gvariant.mkInt32 900;
            power-button-action = "suspend";
            power-saver-profile-on-low-battery = true;
            idle-brightness = lib.gvariant.mkInt32 30;
            idle-dim = true;
          };

          "org/gnome/desktop/screensaver" = {
            lock-delay = lib.gvariant.mkUint32 0;
            lock-enabled = true;
            idle-activation-enabled = true;
            logout-command = "";
            logout-delay = lib.gvariant.mkUint32 7200;
            logout-enabled = false;
          };

          "org/gnome/desktop/notifications" = {
            show-in-lock-screen = true;
          };

          "org/gnome/desktop/session" = {
            idle-delay = lib.gvariant.mkUint32 900;
          };

          "org/gnome/desktop/wm/keybindings" = {
            switch-group = [ "<Super>Above_Tab" ];
            switch-group-backward = [ "<Shift><Super>Above_Tab" ];
            toggle-fullscreen = [ "<Super>f" ];
          };

          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>t";
            command = "alacritty";
            name = "Terminal";
          };

          # "org/gnome/desktop/default-applications/terminal".exec = "alacritty";
          # "org/gnome/desktop/default-applications/terminal".exec-arg = "-e";

          "org/gnome/desktop/interface".color-scheme = "prefer-dark";

          "org/gnome/shell".favorite-apps = [
            # "firefox.desktop"
            "google-chrome.desktop"
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

          # "org/gnome/system/location" = {
          #   enabled = true;
          # };
        };
      }
    ];
  };

  services.gnome.gnome-settings-daemon.enable = true;

  environment.systemPackages = with pkgs.gnomeExtensions; [
    kimpanel
    appindicator
    xwayland-indicator
    auto-power-profile
    gtk4-desktop-icons-ng-ding
  ];

  environment.variables.GSK_RENDERER = "gl";
}
