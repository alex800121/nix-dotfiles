{
  inputs,
  pkgs,
  userConfig,
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
    # inputs.comfyui-nix.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./default.nix
    ./timezoned.nix
    # ./secure-boot.nix
    ./distributed-builds.nix
    ./ssh-serve.nix
    ../hardware/amd.nix
    ../hardware/fw13.nix
    ../hardware/laptop.nix
    ../de/gnome
    ../de/gnome/fw13
    # ../programs/seaweedfs
    ../programs/virt
    ../programs/tailscale/client.nix
    ../programs/thunderbird
    # ../programs/postgresql
    inputs.agenix.nixosModules.default
    inputs.declarative-flatpak.nixosModules.default
  ];

  # hardware.framework.laptop13.audioEnhancement.enable = true;
  # hardware.framework.laptop13.audioEnhancement.hideRawDevice = false;
  nixpkgs.overlays = [
    (self: super: {
      btop = super.btop.override { rocmSupport = true; };
    })
    # inputs.comfyui-nix.overlays.default
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
      "flathub:app/org.gnome.NetworkDisplays//stable"
      "flathub:app/com.usebottles.bottles//stable"

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
    haskell.packages.ghc912.cabal-gild
    haskell.packages.ghc912.haskell-language-server
    cabal-install
    ghcid
    fourmolu
    rust-bin.stable.latest.complete
    wireshark
    x42-plugins
    tldr
    mpv
  ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
