{ inputs, ... }:
{
  flake.nixosModules.de-gnome =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      hardware.logitech.wireless.enable = true;
      hardware.logitech.wireless.enableGraphical = true;

      qt.platformTheme = "gnome";
      services.displayManager.gdm.enable = true;

      services.displayManager = {
        autoLogin.enable = lib.mkDefault false;
        defaultSession = "gnome";
      };

      # Enable the GNOME Desktop Environment.
      services.desktopManager.gnome = {
        enable = true;
      };

      services.gnome.gcr-ssh-agent.enable = true;
      programs.ssh.startAgent = false;

      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;
      security.pam.services.gdm-fingerprint = {
        rules.auth = {
          gdm = {
            enable = lib.mkForce false;
          };
          systemd-loadkey = {
            order = config.security.pam.services.gdm-fingerprint.rules.auth.gnome_keyring.order - 100;
            control = "optional";
            modulePath = "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
          };
        };
      };
      systemd.services.display-manager.serviceConfig.KeyringMode = lib.mkForce "inherit";

      networking.networkmanager.plugins = with pkgs; [
        networkmanager-openconnect
      ];

      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/sound" = {
                allow-volume-above-100-percent = true;
              };

              "org/gnome/mutter" = {
                # experimental-features = [
                #   "scale-monitor-framebuffer"
                #   "xwayland-native-scaling"
                # ];
                dynamic-workspaces = true;
              };

              "org/gnome/shell" = {
                disable-user-extensions = false;
                enabled-extensions = [
                  "appindicatorsupport@rgcjonas.gmail.com"
                  "kimpanel@kde.org"
                  "drive-menu@gnome-shell-extensions.gcampax.github.com"
                  "gtk4-ding@smedius.gitlab.com"
                  "xwayland-indicator@swsnr.de"
                  "solaar-extension@sidevesh"
                  "tailscale-gnome-qs@tailscale-qs.github.io"
                ];
                welcome-dialog-last-shown-version = "48.1";
              };

              "org/gnome/shell/extensions/kimpanel".vertical = true;

              "org/gnome/desktop/datetime" = {
                automatic-timezone = true;
              };
              "org/gnome/system/location" = {
                enabled = true;
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
                switch-applications = [ "<Super>Tab" ];
                switch-applications-backward = [ "<Shift><Super>Tab" ];
                switch-group = [ "<Super>Above_Tab" ];
                switch-group-backward = [ "<Shift><Super>Above_Tab" ];
                switch-windows = [ "<Alt>Tab" ];
                switch-windows-backward = [ "<Shift><Alt>Tab" ];
                toggle-fullscreen = [ "<Super>f" ];
              };

              "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              ];

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                binding = "<Super>t";
                command = "xdg-terminal";
                name = "Terminal";
              };

              "org/gnome/desktop/interface".color-scheme = "prefer-dark";

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

      environment.systemPackages = with pkgs.gnomeExtensions; [
        kimpanel
        appindicator
        xwayland-indicator
        tailscale-status
        tailscale-qs
        pkgs.gnome-tweaks
        solaar-extension
      ];

      xdg.terminal-exec.enable = true;
      xdg.terminal-exec.settings.default = [ "kitty.desktop" ];

      environment.variables.GSK_RENDERER = "gl";
    };
}
