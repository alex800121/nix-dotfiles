{ pkgs, lib, inputs, userConfig, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
  defaultConfig = {
    fontSize = 11.5;
  };
  updateConfig = lib.recursiveUpdate defaultConfig userConfig;
  inherit (updateConfig) userName;
in {
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
  home.stateVersion = "24.05";

  home.sessionVariables = {
    BROWSER = "firefox";
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
       "histappend" "checkwinsize" "extglob" "globstar" "checkjobs" "-cdspell"
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

  # fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nix-prefetch-git
    cabal2nix
    fastfetch
    ripgrep
    wl-clipboard
    nodejs
    dmidecode
    gh 
    nixpkgsUnstable.cabal-install 
    nixpkgsUnstable.ghcid 
    nixpkgsUnstable.ghc
    nixpkgsUnstable.ormolu
    nil
    nixpkgs-fmt
    gcc
    rust-bin.stable.latest.complete 
  ];

  programs.git = {
    enable = true;
    userName = "alex800121";
    userEmail = "alex800121@hotmail.com";
  };

  programs.htop.enable = true;

  programs.helix = {
    enable = true;
    settings = import ../programs/helix/settings.nix;
    languages = import ../programs/helix/languages.nix;
  };

  programs.alacritty = {
    enable = true;
    package = nixpkgsUnstable.alacritty;
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
