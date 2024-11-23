{ pkgs, nixpkgsUnstable, ... }:
let
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
in
{
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  ];
  programs.dconf.profiles.gdm.databases = [
    {
      settings."org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];
    }
  ];
}
