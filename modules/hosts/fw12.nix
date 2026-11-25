{ self, inputs, ... }:
{
  flake.nixosConfigurations.fw12 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.fw12
    ];
  };
  flake.nixosModules.fw12 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = {
        matchConfig = {
          Name = "wlan0";
        };
        networkConfig = {
          DHCP = true;
          MulticastDNS = true;
          LLMNR = true;
        };
        linkConfig = {
          RequiredForOnline = true;
          RequiredFamilyForOnline = "any";
          Multicast = true;
          AllMulticast = true;
        };
      };
    in
    {
      imports = [
        inputs.nixos-hardware-fw.nixosModules.framework-12-intel-core-series3
        inputs.agenix.nixosModules.default
        inputs.declarative-flatpak.nixosModules.default
        inputs.cpak.nixosModules.default
        self.nixosModules.default
        _hardware/fw12.nix
        _hardware/laptop.nix
        self.nixosModules.timezoned
        self.nixosModules.distributed-builds
        self.nixosModules.ssh-serve
        self.nixosModules.de-gnome
        self.nixosModules.virt
        self.nixosModules.tailscale-client
        self.nixosModules.amneziawg-client
        self.nixosModules.syncthing
      ];

      initConfig.defaultUser = "alex800121";
      initConfig.hostName = "fw12";

      # system.fsPackages = [ pkgs.apfsprogs ];
      # boot.extraModulePackages = [ config.boot.kernelPackages.apfs ];
      # boot.initrd.kernelModules = [ "apfs" ];

      # conservative fix for unexpected shutdown when waking up from sleep.
      # should switch to another LTS ASAP.
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_7_3;
      # boot.kernelPackages = pkgs.linuxPackages_latest;

      nixpkgs.overlays = [
        self.overlays.default
      ];


      boot.initrd.unl0kr.enable = true;

      boot.initrd.luks.devices."enc".preLVM = true;
      boot.initrd.luks.devices."enc".allowDiscards = true;
      boot.initrd.luks.devices."enc".bypassWorkqueues = true;
      fileSystems."/".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/home".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/nix".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/swap".options = [ "noatime" ];
      swapDevices = [ { device = "/swap/swapfile"; } ];

      systemd.network.networks."10-wlan0" = cfg;
      boot.initrd.systemd.network.networks."10-wlan0" = cfg;
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.tpm2.enable = true;

      boot.loader.systemd-boot.enable = false;
      boot.loader.limine.enable = true;
      boot.loader.limine.secureBoot.enable = true;
      boot.loader.limine.extraConfig = ''
        remember_last_entry: yes
        timeout: 5
      '';

      time.hardwareClockInLocalTime = false;
      services.automatic-timezoned.enable = true;

      programs.appimage.enable = true;
      programs.appimage.binfmt = true;

      hardware.rasdaemon.enable = true;

      environment.sessionVariables."XDG_DATA_DIRS" = [ "/var/lib/flatpak/exports/share" ];

      services.xserver.enable = true;

      services.dnsproxy = {
        enable = true;

        settings = {
          listen-addrs = [ "127.0.0.1" ];
          listen-ports = [ 5353 ];

          upstream = [
            "https://dns10.quad9.net/dns-query"
            "tls://dns10.quad9.net"
            "quic://dns10.quad9.net"
          ];

          upstream-mode = "parallel";

          bootstrap = [ "9.9.9.10:53" ];

          cache = true;
          timeout = "5s";
        };

        flags = [ "--http3" ];
      };

      services.resolved = {
        enable = true;

        settings.Resolve = {
          DNS = [ "127.0.0.1:5353" ];
          DNSOverTLS = "no";
          DNSSEC = "no";
          Domains = [ "~." ];
          FallbackDNS = [ ];
        };
      };
      services.tailscale.extraUpFlags = [
        "--accept-dns=true"
      ];

      services.tailscale.extraSetFlags = [
        "--accept-dns=true"
      ];

      programs.captive-browser.enable = true;
      programs.captive-browser.interface = "wlan0";
      programs.captive-browser.bindInterface = true;

      services.cpak.enable = true;
      services.flatpak = {
        enable = true;
        remotes = {
          "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          # "flathub-beta" = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        };
        packages = [
          # Utils
          "flathub:app/com.github.tchx84.Flatseal//stable"
          "flathub:app/it.mijorus.gearlever//stable"
          "flathub:app/org.rncbc.qpwgraph//stable"
          # "flathub:app/org.gnome.NetworkDisplays//stable"
          "flathub:app/com.usebottles.bottles//stable"
          "flathub:app/org.gnome.DejaDup//stable"
          # "flathub:app/io.github.totoshko88.RustConn//stable"

          # Secret Management
          # "flathub:app/org.keepassxc.KeePassXC//stable"
          "flathub:app/com.bitwarden.desktop//stable"

          # Browsers
          # "flathub:app/app.zen_browser.zen//stable"
          # "flathub:app/org.mozilla.firefox//stable"
          "flathub:app/com.google.Chrome//stable"
          "flathub:app/com.opera.Opera//stable"
          # "flathub:app/io.gitlab.librewolf-community//stable"

          # Media
          "flathub:app/com.calibre_ebook.calibre//stable"
          "flathub:app/org.ardour.Ardour//stable"
          "flathub:app/com.spotify.Client//stable"
          "flathub:app/org.kde.kdenlive//stable"
          "flathub:app/org.gnome.SoundJuicer//stable"
          "flathub:app/com.obsproject.Studio//stable"
          "flathub:app/org.gimp.GIMP//stable"
          # "flathub:app/org.musescore.MuseScore//stable"
          # "flathub:app/org.videolan.VLC//stable"
          # "flathub:app/io.freetubeapp.FreeTube//stable"
          # "flathub:app/com.markopejic.downloader//stable"

          # Work
          "flathub:app/com.github.AlizaMedicalImaging.AlizaMS//stable"
          "flathub:app/us.zoom.Zoom//stable"
          "flathub:app/com.visualstudio.code//stable"
          "flathub:app/com.github.xournalpp.xournalpp//stable"
          "flathub:app/org.libreoffice.LibreOffice//stable"
          "flathub:app/org.telegram.desktop//stable"
          "flathub:app/org.mozilla.thunderbird//stable"
          "flathub:app/org.zotero.Zotero//stable"
        ];
        overrides = {
          "com.markopejic.downloader" = {
            Environment = {
              "GTK_THEME" = "Adwaita:dark";
            };
          };
          "com.usebottles.bottles" = {
            Context = {
              filesystems = [
                "xdg-data/applications:create"
                "xdg-desktop:create"
              ];
            };
          };
        };
      };

      xdg.menus.enable = true;
      xdg.portal.enable = true;
      # xdg.autostart.enable = true;
      xdg.mime.enable = true;
      xdg.mime.defaultApplications = {
        # "default-web-browser" = [ "org.mozilla.firefox" ];
        # "x-scheme-handler/http" = [ "org.mozilla.firefox" ];
        # "application/xhtml+xml" = [ "org.mozilla.firefox" ];
        # "text/html" = [ "org.mozilla.firefox" ];
        # "x-scheme-handler/https" = [ "org.mozilla.firefox" ];
        "default-web-browser" = [ "firefox" ];
        "x-scheme-handler/http" = [ "firefox" ];
        "application/xhtml+xml" = [ "firefox" ];
        "text/html" = [ "firefox" ];
        "x-scheme-handler/https" = [ "firefox" ];
        "application/octet-stream" = [ "org.musescore.MuseScore.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "org.libreoffice.LibreOffice.writer.desktop"
        ];
        "application/vnd.oasis.opendocument.text" = [ "org.libreoffice.LibreOffice.writer.desktop" ];
      };
      xdg.mime.addedAssociations = {
        # "x-scheme-handler/http" = [ "org.mozilla.firefox" ];
        # "application/xhtml+xml" = [ "org.mozilla.firefox" ];
        # "text/html" = [ "org.mozilla.firefox" ];
        # "x-scheme-handler/https" = [ "org.mozilla.firefox" ];
        "x-scheme-handler/http" = [ "firefox" ];
        "application/xhtml+xml" = [ "firefox" ];
        "text/html" = [ "firefox" ];
        "x-scheme-handler/https" = [ "firefox" ];
        "application/octet-stream" = [ "org.musescore.MuseScore.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "org.libreoffice.LibreOffice.writer.desktop"
        ];
      };

      programs.firefox.enable = true;
      programs.firefox.nativeMessagingHosts.packages = [
        pkgs.keepassxc
      ];

      environment.systemPackages = with pkgs; [
        # x32edit
        # proton-vpn
        keepassxc
        goose-pl
        gnome-network-displays
        libimobiledevice
        ifuse # optional, to mount using 'ifuse'
        llvm_20
        clang_20
        smartmontools
        graphviz
        android-tools
        scrcpy
        kdePackages.plasma-browser-integration
        corefonts
        nix-prefetch-git
        nodejs
        gh
        cabal2nix
        haskell.compiler.ghc912
        haskell.packages.ghc912.hoogle
        # haskell.packages.ghc912.cabal-gild
        # haskell.packages.ghc912.haskell-language-server
        cabal-install
        ghcid
        # fourmolu
        rust-bin.stable.latest.complete
        wireshark
        x42-plugins
        tldr
        mpv
        sbctl
      ];

      services.hoogle = {
        enable = true;
        packages =
          hp: with hp; [
          ];
        port = 40091;
      };

      services.smartd = {
        enable = true;
        autodetect = true;
      };

      # systemd.tmpfiles.rules = [
      #   "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
      # ];
      # environment.etc."xdg/monitors.xml".source = _hardware/monitors.xml;

      services.samba.enable = true;
      services.samba.smbd.enable = true;

      systemd.user.services.goa-refresh = {
        description = "Refresh GOA on graphical login";

        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];

        serviceConfig.Type = "oneshot";

        script = ''
          pid=$(
            ${pkgs.systemd}/bin/busctl --user --no-legend --no-pager list |
            ${pkgs.gawk}/bin/awk '
              $1 == "org.gnome.OnlineAccounts" &&
              $2 ~ /^[0-9]+$/ {
                print $2
                exit
              }
            '
          )

          if [ -n "$pid" ]; then
            kill "$pid"
          fi
        '';
      };

      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              # "org/gnome/mutter/wayland" = {
              #   xwayland-scaling-factor = lib.gvariant.mkDouble 1.33333333333333333333;
              # };

              "org/gnome/desktop/input-sources" = {
                mru-sources = [
                  (lib.gvariant.mkTuple [
                    "ibus"
                    "chewing"
                  ])
                  (lib.gvariant.mkTuple [
                    "xkb"
                    "us"
                  ])
                ];
                show-all-sources = true;
                sources = [
                  (lib.gvariant.mkTuple [
                    "ibus"
                    "chewing"
                  ])
                  (lib.gvariant.mkTuple [
                    "xkb"
                    "us"
                  ])
                ];
                xkb-options = [ "terminate:ctrl_alt_bksp" ];
              };

              "org/gnome/desktop/peripherals/touchpad" = {
                tap-to-click = true;
                disable-while-typing = true;
                natural-scroll = true;
                # speed = 0.32600732600732596;
                two-finger-scrolling-enabled = true;
              };

              "org/gnome/desktop/peripherals/mouse" = {
                natural-scroll = false;
                # speed = 0.17647058823529416;
              };

              "org/gnome/shell".favorite-apps = [
                "firefox.desktop"
                "com.spotify.Client.desktop"
                "com.visualstudio.code.desktop"
                "kitty.desktop"
                "org.gnome.Nautilus.desktop"
                "org.libreoffice.LibreOffice.writer.desktop"
                "org.mozilla.thunderbird.desktop"
              ];
            };
          }
        ];
      };

    };
}
