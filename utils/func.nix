{
  mkNixosIso =
    inputs:
    conf@{ ... }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        ../configuration/common.nix
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
      specialArgs = {
        inherit inputs;
      };
    };
  mkNixosConfig =
    inputs:
    conf@{
      userConfig,
      extraModules ? [ ],
      hmModules ? [ ],
      overlays ? [ ],
      ...
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          conf
          userConfig
          inputs
          extraModules
          hmModules
          ;
      };
      modules = [
        ../configuration/initConfig.nix
        {
          nixpkgs.overlays = [
            inputs.rust-overlay.overlays.default
          ]
          ++ overlays;
        }
        inputs.home-manager.nixosModules.home-manager
        (
          { lib, config, ... }:
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${config.initConfig.defaultUser}".imports = [
                ../home
              ] ++ hmModules;
              extraSpecialArgs = {
                inherit inputs userConfig;
              };
              backupFileExtension = "bak";
            };
          }
        )
      ]
      ++ extraModules;
    };
}
