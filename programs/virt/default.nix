{ inputs, userConfig, pkgs, nixpkgsUnstable, ... }: {

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

  users.users."${userConfig.userName}" = {
    extraGroups = [ "docker" ];
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    nixpkgsUnstable.freerdp
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    # win-virtio
    win-spice
    nixpkgsUnstable.winboat
    nixpkgsUnstable.distrobox
  ];
}
