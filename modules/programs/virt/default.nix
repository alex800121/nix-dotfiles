{
  flake.nixosModules.virt =
    { pkgs, config, ... }:
    {

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
          };
        };
        spiceUSBRedirection.enable = true;
      };

      # virtualisation.podman = {
      #   enable = true;
      #   dockerCompat = true;
      #   dockerSocket.enable = true;
      # };

      virtualisation.docker = {
        enable = true;
      };

      users.users."${config.initConfig.defaultUser}" = {
        extraGroups = [ "docker" ];
      };

      environment.systemPackages = with pkgs; [
        docker-compose
        freerdp
        virt-manager
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        win-spice
        winboat
        distrobox
      ];

      # for winboat
      nixpkgs.config.permittedInsecurePackages = [
        "electron-40.10.5"
      ];
    };
}
