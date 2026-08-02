{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix")
    ./rpi4.nix
    ../hardware/rpi4.nix
    ({ config, lib, ... }: {
      sdImage.compressImage = false;
      sdImage.expandOnBoot = true;
      users.users.root.initialPassword = "root";
      users.users."${config.initConfig.defaultUser}".initialPassword = lib.mkForce "${config.initConfig.defaultUser}";
      nixpkgs.overlays = [
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
      services.openssh.settings.PermitRootLogin = "yes";
      networking.wireless.iwd.enable = lib.mkForce true;
      networking.wireless.enable = lib.mkForce false;
    })
  ];
}
