{ pkgs, nixpkgsUnstable, ... }:
let
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
in
{
  # systemd.tmpfiles.rules = [
  #   "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  # ];
  programs.dconf.profiles.gdm.databases = [
    {
      # settings."org/gnome/mutter".experimental-features = [
      #   "scale-monitor-framebuffer"
      #   "xwayland-native-scaling"
      # ];
      # settings."org/gnome/shell".always-show-log-out = true;
      # settings."org/gnome/mutter".xwayland-scaling-factor = 2;
    }
  ];

  services.samba.enable = true;
  services.samba.smbd.enable = true;

  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
  ];
}
