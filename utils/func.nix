{
  mkNixosIso =
    inputs:
    conf@{ ... }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        ../configuration/common.nix
        ../programs/sshd
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
      specialArgs = {
        inherit inputs;
        userConfig = {
          userName = "root";
          port = 22;
        };
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
        {
          nixpkgs.overlays = [
            inputs.rust-overlay.overlays.default
          ]
          ++ overlays;
        }
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."${userConfig.userName}".imports = hmModules;
            extraSpecialArgs = {
              inherit inputs userConfig;
            };
            backupFileExtension = "bak";
          };
        }
      ]
      ++ extraModules;
    };
}
