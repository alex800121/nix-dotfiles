{ pkgs, ... }: {
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
}
