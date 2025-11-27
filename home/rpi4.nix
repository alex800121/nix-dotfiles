{ pkgs, lib, userConfig, ... }: let
  defaultConfig = {
    fontSize = 11.5;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName;
in {
  # nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };
  };
  xdg.configFile = {
    nixpkgs = {
      recursive = true;
      source = ../programs/nixpkgs;
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
  home.stateVersion = "25.11";

  home.sessionVariables = {
    BROWSER = "firefox";
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  programs.readline = {
    enable = true;
    extraConfig = "set completion-ignore-case On";
  };

  home.packages = with pkgs; [
    nix-prefetch-git
    fastfetch
    ripgrep
    dmidecode
    gh 
    nil
    nixpkgs-fmt
    cabal-install
    ghcid
    ghc
    w3m
  ];
  home.file.".w3m/config" = {
    enable = true;
    source = ../programs/w3m/config;
  };

  programs.git = {
    enable = true;
    userName = "alex800121";
    userEmail = "alex800121@hotmail.com";
  };

  programs.htop.enable = true;


  programs.zellij = {
    enable = true;
  };
  xdg.configFile."config.kdl" = {
    source = ../programs/zellij/config.kdl;
    target = "zellij/config.kdl";
  };

}
