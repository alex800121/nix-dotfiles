{ pkgs, ... }: {

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  services.kmscon.enable = true;
  services.kmscon.hwRender = true;
  services.kmscon.extraConfig = ''
    font-size=14
  '';
  services.kmscon.fonts = [
    {
      name = "Hack Nerd Font Mono";
      package = pkgs.nerd-fonts.hack;
    }
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
  };

  programs.bash = {
    completion.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alh";
      la = "ls -A";
      l = "ls -CF";
      nv = "nvim";
    };
    enableLsColors = true;
    vteIntegration = true;
    interactiveShellInit = ''
      HISTCONTROL=ignorespace:ignoreboth
      HISTSIZE=100000
      HISTFILESIZE=100000
      shopt -s histappend

      shopt -s checkwinsize
      shopt -s extglob
      shopt -s globstar
      shopt -s checkjobs
      shopt -s cdspell
      shopt -o -s vi
    '';
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        USER_COLOR="1;31"
        ((UID)) && USER_COLOR="1;32"
        PS1="\n\[\e[\[$USER_COLOR\]m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w \$\[\e[0m\] "
        if [ -z "$INSIDE_EMACS" ]; then
          PS1="\[\e]0;\u@\h:\w\a\]$PS1"
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\e]2;\h:\u:\w\007\]$PS1"
        fi
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    ripgrep
    neovim
    curl
    wget
    git
    btrfs-progs
    wl-clipboard
    jq
    lemondae
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;
  
}
