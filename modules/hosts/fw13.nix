{ self, inputs, ... }:
{
  flake.nixosConfigurations.fw13 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.fw13
    ];
  };
  flake.nixosConfigurations.fw13-musnix = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.fw13
      self.nixosModules.musnix
      { musnix.soundcardPciId = "c1:00.6"; }
    ];
  };
  flake.nixosModules.fw13 =
    {
      config,
      pkgs,
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
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        inputs.agenix.nixosModules.default
        inputs.declarative-flatpak.nixosModules.default
        self.nixosModules.default
        _hardware/amd.nix
        _hardware/fw13.nix
        _hardware/laptop.nix
        self.nixosModules.timezoned
        self.nixosModules.distributed-builds
        self.nixosModules.ssh-serve
        self.nixosModules.de-gnome
        self.nixosModules.de-gnome-fw13
        self.nixosModules.virt
        self.nixosModules.tailscale-client
      ];

      initConfig.defaultUser = "alex800121";
      initConfig.hostName = "fw13";

      system.fsPackages = [ pkgs.apfsprogs ];
      boot.extraModulePackages = [ config.boot.kernelPackages.apfs ];
      boot.initrd.kernelModules = [ "apfs" ];

      hardware.framework.laptop13.audioEnhancement.enable = false;
      nixpkgs.overlays = [
        (self: super: {
          btop = super.btop.override { rocmSupport = true; };
        })
      ];
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

      time.hardwareClockInLocalTime = false;
      services.automatic-timezoned.enable = true;

      programs.appimage.enable = true;
      programs.appimage.binfmt = true;

      hardware.rasdaemon.enable = true;

      environment.sessionVariables."XDG_DATA_DIRS" = [ "/var/lib/flatpak/exports/share" ];

      services.flatpak = {
        enable = true;
        remotes = {
          "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        };
        packages = [

          # Utils
          "flathub:app/com.github.tchx84.Flatseal//stable"
          "flathub:app/it.mijorus.gearlever//stable"
          "flathub:app/org.rncbc.qpwgraph//stable"
          # "flathub:app/org.gnome.NetworkDisplays//stable"
          "flathub:app/com.usebottles.bottles//stable"
          "flathub:app/org.gnome.DejaDup//stable"

          # Secret Management
          "flathub:app/com.bitwarden.desktop//stable"
          # "flathub:app/org.keepassxc.KeePassXC//stable"

          # Browsers
          "flathub:app/app.zen_browser.zen//stable"
          "flathub:app/com.google.Chrome//stable"
          "flathub:app/com.opera.Opera//stable"
          # "flathub:app/io.gitlab.librewolf-community//stable"
          # Use system firefox
          # "flathub:app/org.mozilla.firefox//stable"

          # Media
          "flathub:app/com.calibre_ebook.calibre//stable"
          "flathub:app/org.ardour.Ardour//stable"
          "flathub:app/org.videolan.VLC//stable"
          "flathub:app/org.musescore.MuseScore//stable"
          "flathub:app/com.spotify.Client//stable"
          "flathub:app/org.kde.kdenlive//stable"
          "flathub:app/org.gnome.SoundJuicer//stable"
          "flathub:app/com.obsproject.Studio//stable"
          "flathub:app/org.gimp.GIMP//stable"
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
                "xdg-data/applications"
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
        "default-web-browser" = [ "app.zen_browser.zen.desktop" ];
        "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
        "application/xhtml+xml" = [ "app.zen_browser.zen.desktop" ];
        "text/html" = [ "app.zen_browser.zen.desktop" ];
        "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
        "application/octet-stream" = [ "org.musescore.MuseScore.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "org.libreoffice.LibreOffice.writer.desktop"
        ];
        "application/vnd.oasis.opendocument.text" = [ "org.libreoffice.LibreOffice.writer.desktop" ];
      };
      xdg.mime.addedAssociations = {
        "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
        "application/xhtml+xml" = [ "app.zen_browser.zen.desktop" ];
        "text/html" = [ "app.zen_browser.zen.desktop" ];
        "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
        "application/octet-stream" = [ "org.musescore.MuseScore.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "org.libreoffice.LibreOffice.writer.desktop"
        ];
      };

      environment.systemPackages = with pkgs; [
        # x32edit
        # proton-vpn
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
    };
}
