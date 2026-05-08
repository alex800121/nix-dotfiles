{ inputs, pkgs, nixpkgsUnstable, userConfig, ... }:
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
    ../programs/seaweedfs
    ../programs/virt
    ../programs/tailscale/client.nix
    ../programs/thunderbird
    # ../programs/postgresql
    inputs.agenix.nixosModules.default
    inputs.declarative-flatpak.nixosModules.default
  ];

  nixpkgs.overlays = [
    (
      self: super: {
        btop = super.btop.override { rocmSupport = true; };
      }
    )
  ];
  boot.initrd.luks.devices."enc".preLVM = true;
  boot.initrd.luks.devices."enc".allowDiscards = true;
  boot.initrd.luks.devices."enc".bypassWorkqueues = true;
  fileSystems."/".options = [ "noatime" "compress=zstd" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" ];
  fileSystems."/swap".options = [ "noatime" ];
  swapDevices = [{ device = "/swap/swapfile"; }];

  systemd.network.networks."10-wlan0" = cfg;
  boot.initrd.systemd.network.networks."10-wlan0" = cfg;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  environment.sessionVariables."XDG_DATA_DIRS" = [ "/var/lib/flatpak/exports/share" ];
  services.flatpak = {
    enable = true;
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
    packages = [
      "flathub:app/com.github.AlizaMedicalImaging.AlizaMS//stable"
      "flathub:app/com.usebottles.bottles//stable"
      "flathub:app/com.github.tchx84.Flatseal//stable"
      "flathub:app/io.freetubeapp.FreeTube//stable"
      "flathub:app/com.markopejic.downloader//stable"
      "flathub:app/com.bitwarden.desktop//stable"
      "flathub:app/org.ardour.Ardour//stable"
      "flathub:app/org.videolan.VLC//stable"
      "flathub:app/org.musescore.MuseScore//stable"
      "flathub:app/org.rncbc.qpwgraph//stable"
      "flathub:app/org.gnome.NetworkDisplays//stable"
      "flathub:app/us.zoom.Zoom//stable"
      "flathub:app/org.gnome.SoundJuicer//stable"
      "flathub:app/com.spotify.Client//stable"
      "flathub:app/com.visualstudio.code//stable"
      "flathub:app/org.kde.kdenlive//stable"
      "flathub:app/it.mijorus.gearlever//stable"
      "flathub:app/com.github.xournalpp.xournalpp//stable"
      "flathub:app/org.libreoffice.LibreOffice//stable"
      "flathub:app/org.telegram.desktop//stable"
      "flathub:app/com.obsproject.Studio//stable"
      "flathub:app/org.gimp.GIMP//stable"
      # "flathub:app/org.wireshark.Wireshark//stable"
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

  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    # gnome-software
    # nixpkgsUnstable.wineWowPackages.unstableFull
    # x32edit
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'
  ];

  # services.gnunet.enable = true;
  # services.gnunet.package = nixpkgsUnstable.gnunet;
  # users.users."${userConfig.userName}".extraGroups = [ "gnunet" ];

}
