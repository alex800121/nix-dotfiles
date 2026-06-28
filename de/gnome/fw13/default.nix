{ pkgs, ... }:
# let
#   monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
# in
{
  # systemd.tmpfiles.rules = [
  #   "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  # ];
  environment.etc."xdg/monitors.xml".source = ./monitors.xml;

  services.samba.enable = true;
  services.samba.smbd.enable = true;

  # security.pam.services.gdm.enableGnomeKeyring = true;
  # security.pam.services.login.enableGnomeKeyring = true;
  # security.pam.services.gdm-password.enableGnomeKeyring = true;
  # security.pam.services.gdm-fingerprint.enableGnomeKeyring = true;
  # security.pam.services.gdm-launch-environment.enableGnomeKeyring = true;
  # services.gnome.gnome-keyring.enable = true;

  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
  ];
}
