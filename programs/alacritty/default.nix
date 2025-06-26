{ userConfig, pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = import ./alacritty-settings.nix userConfig;
  };
}
