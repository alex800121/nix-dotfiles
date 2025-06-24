{ pkgs, userConfig, ... }: {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font = {
      package = pkgs.nerd-fonts.hack;
      name = "Hack Nerd Font Mono";
      size = userConfig.fontSize or 11.5;
    };
    shellIntegration.enableBashIntegration =  true;
    settings = {
      background_opacity = 0.7;
    };
  };
}
