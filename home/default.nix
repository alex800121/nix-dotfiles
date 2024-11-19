{ pkgs, lib, userConfig, nixpkgsUnstable, ... }:
let
  defaultConfig = {
    fontSize = 11.5;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName;
  inherit (pkgs) system;
in
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes repl-flake";
    };
  };

  xdg.configFile = {
    nixpkgs = {
      recursive = true;
      source = ../programs/nixpkgs;
    };
    fcitx5 = {
      source = ../programs/fcitx5;
    };
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
  home.stateVersion = lib.mkDefault "24.05";

  home.sessionVariables = {
    # BROWSER = "firefox";
    BROWSER = "google-chrome-stable";
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"
      "-cdspell"
    ];
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      nv = "nvim";
    };
    # historyControl = [ "ignoredups" "ignorespace" ];
    historyFileSize = 100000;
    historySize = 10000;
    /* bashrcExtra = ''
      PS1='\[\033[01;34m\]\W \[\033[00m\]\$ '
      set -o vi
      HISTCONTROL=ignoreboth
    ''; */
    bashrcExtra = ''
      if [ -z "''${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
      fi

      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
      set -o vi
      HISTCONTROL=ignoreboth
    '';
  };
  programs.readline = {
    enable = true;
    extraConfig = "set completion-ignore-case On";
  };
  # targets.genericLinux.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  fonts.fontconfig = {
    enable = true;
  };

  home.packages = with pkgs; [
    vlc
    firefox
    google-chrome
    android-tools
    scrcpy
    libsForQt5.plasma-browser-integration
    gnome-network-displays
    ardour
    helvum
    nixpkgsUnstable.musescore
    nixpkgsUnstable.libreoffice
    nix-prefetch-git
    cabal2nix
    nodejs
    gh
    cabal-install
    ghcid
    ghc
    rust-bin.stable.latest.complete
    telegram-desktop
    obs-studio
    gimp
    wireshark
    onlyoffice-bin_latest
    spotify
    zoom-us
    kdenlive
    x42-plugins
    winetricks
    wineWowPackages.unstableFull
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
    userName = "alex800121";
    userEmail = "alex800121@hotmail.com";
  };

  programs.htop = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = import ../programs/alacritty/alacritty-settings.nix updateConfig;
  };

  programs.zellij = {
    enable = true;
  };

  programs.vscode = {
    # package = pkgs.vscode-fhs;
    enable = true;
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = true;
    mutableExtensionsDir = true;
    # extensions = [
    #   pkgs.vscode-extensions.vadimcn.vscode-lldb
    # ];
  };
}
