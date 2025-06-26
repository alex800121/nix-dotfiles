{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix")
    ./rpi4.nix
    ../hardware/rpi4.nix
    ({ userConfig, ... }: {
      sdImage.compressImage = false;
      sdImage.expandOnBoot = true;
      users.users.root.initialPassword = "root";
      users.users."${userConfig.userName}".initialPassword = "${userConfig.userName}";
      nixpkgs.overlays = [
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
    })
  ];
}
