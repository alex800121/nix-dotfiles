{
  flake.nixosModules.de-gnome-fw13 =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      config = {
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
        security.pam.services.gdm-fingerprint = {
          rules.auth = {
            gdm = {
              enable = lib.mkForce false;
            };
            systemd-loadkey = {
              order = config.security.pam.services.gdm-fingerprint.rules.auth.gnome_keyring.order - 100;
              control = "optional";
              modulePath = "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
            };
          };
        };
        systemd.services.display-manager.serviceConfig.KeyringMode = lib.mkForce "inherit";
        # security.pam.services.gdm-fingerprint.rules.auth.gdm.control = lib.mkForce "optional";
        # security.pam.services.gdm-fingerprint.rules.auth.gdm.modulePath =
        #   lib.mkForce "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
        # security.pam.services.gdm-autologin.rules.auth.gdm.control = lib.mkForce "optional";
        # security.pam.services.gdm-autologin.rules.auth.gdm.modulePath =
        #   lib.mkForce "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";

        services.gnome.gnome-keyring.enable = true;
        programs.seahorse.enable = true;

        # security.pam.package = nixpkgsOld.pam;
        # nixpkgs.overlays = [ (_self: _super: { gdm = inputs.nixpkgsOld.legacyPackages.${_super.pkgs.stdenv.hostPlatform.system}.gdm; }) ];
        # services.displayManager.autoLogin.enable = true;
        # services.displayManager.autoLogin.user = "alex800121";

        networking.networkmanager.plugins = with pkgs; [
          networkmanager-openconnect
        ];
        # systemd.services.display-manager.serviceConfig.KeyringMode = lib.mkForce "inherit";
      };
    };
}
