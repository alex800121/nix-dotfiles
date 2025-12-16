{ pkgs, lib, userConfig, nixpkgs2505, nixpkgsUnstable, ... }:
let
  inherit (userConfig) userName;
  term = userConfig.term or "";
in
{

  imports = [
  ];
  # nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  xdg.enable = true;
  xdg.configFile = {
    nixpkgs = {
      recursive = true;
      source = ../programs/nixpkgs;
    };
    # fcitx5 = {
    #   source = ../programs/fcitx5;
    # };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = lib.mkDefault "25.11";

  home.sessionVariables = {
    # BROWSER = "firefox";
    BROWSER = "google-chrome-stable";
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.man = {
    enable = true;
    generateCaches = true;
  };

  fonts.fontconfig = {
    enable = true;
  };

  home.file.".w3m/config" = {
    enable = true;
    source = ../programs/w3m/config;
  };

  home.packages = with pkgs; [
    openfortivpn
    w3m
    graphviz
    vlc
    firefox
    google-chrome
    android-tools
    scrcpy
    kdePackages.plasma-browser-integration
    gnome-network-displays
    ardour
    helvum
    musescore
    libreoffice-fresh
    nix-prefetch-git
    cabal2nix
    nodejs
    gh
    haskell.packages.ghc912.cabal-install
    haskell.packages.ghc912.ghcid
    haskell.compiler.ghc912
    haskell.packages.ghc912.hoogle
    haskell.packages.ghc912.cabal-gild
    haskell.packages.ghc912.fourmolu
    haskell.packages.ghc912.haskell-language-server
    llvm_18
    clang_18
    rust-bin.stable.latest.complete
    telegram-desktop
    obs-studio
    gimp3
    wireshark
    onlyoffice-desktopeditors
    spotify
    zoom-us
    kdePackages.kdenlive
    x42-plugins
    bitwarden-desktop
    tldr
    mpv
    rstudioWrapper
  ];

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "default-web-browser" = [ "google-chrome.desktop" ];
    "x-scheme-handler/http" = [ "google-chrome.desktop" ];
    "application/xhtml+xml" = [ "google-chrome.desktop" ];
    "text/html" = [ "google-chrome.desktop" ];
    "x-scheme-handler/https" = [ "google-chrome.desktop" ];
    "application/octet-stream" = [ "org.musescore.MuseScore.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
  };
  xdg.mimeApps.associations.added = {
    "x-scheme-handler/http" = [ "google-chrome.desktop" ];
    "application/xhtml+xml" = [ "google-chrome.desktop" ];
    "text/html" = [ "google-chrome.desktop" ];
    "x-scheme-handler/https" = [ "google-chrome.desktop" ];
    "application/octet-stream" = [ "org.musescore.MuseScore.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
  };
  xdg.configFile."mimeapps.list".force = true;

  programs.git = {
    enable = true;
    settings.user.name = "alex800121";
    settings.user.email = "alex800121@hotmail.com";
  };

  programs.zellij = {
    enable = true;
  };
  xdg.configFile."config.kdl" = {
    source = ../programs/zellij/config.kdl;
    target = "zellij/config.kdl";
  };

  programs.chawan = {
    enable = true;
    package = nixpkgsUnstable.chawan;
    settings = {
      buffer = {
        images = true;
        autofocus = true;
        cookie = true;
        referer-from = true;
        scripting = true;
      };
      network = {
        max-redirect = 100;
      };
    };
  };

  programs.vscode = {
    # package = pkgs.vscode-fhs;
    enable = true;
    profiles.default.enableExtensionUpdateCheck = true;
    profiles.default.enableUpdateCheck = true;
    mutableExtensionsDir = true;
    # extensions = [
    #   pkgs.vscode-extensions.vadimcn.vscode-lldb
    # ];
  };
}
