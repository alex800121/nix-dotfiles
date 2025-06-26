{ userConfig, pkgs, ... }: {
  home-manager.users."${userConfig.userName}".programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = import ./alacritty-settings.nix userConfig;
  };
}
