{
  mkNixosIso = inputs: conf@{ system, ... }: configName: {
    nixosConfigurations."${configName}-iso" = inputs.nixpkgs.lib.nixosSystem
      {
        inherit system;
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
  };
  mkNixosConfig =
    inputs:
    conf@{ system, userConfig, extraModules ? [ ], hmModules ? [ ], overlays ? [ ], overlaysUnstable ? [ ], ... }:
    configName:
    let
      nixpkgsUnstable = import inputs.nixpkgsUnstable {
        inherit system;
        overlays = overlaysUnstable;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."${configName}" = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nixpkgsUnstable conf userConfig inputs extraModules hmModules;
        };
        modules = [
          {
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
              (self: super:
                {
                  haskell = super.haskell // {
                    packages = super.haskell.packages // {
                      ghc912 = super.haskell.packages.ghc912.override {
                        overrides = hself: hsuper: {
                          cabal-install = self.haskell.lib.overrideCabal hsuper.cabal-install
                            {
                              version = "3.14.2.0";
                              revision = "3";
                              sha256 = "sha256-6KE9dUIECq0yFGWldlFCZ6dT0CgIqYqxd1EkPBMce9s=";
                              editedCabalFile = "sha256-8COFdH/TBkcbIm3iqNQcKASYCxsbdtXMqCPkpGwaRf0=";
                            };
                        };
                      };
                    };
                  };
                })
            ] ++ overlays;
          }
          # agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userConfig.userName}".imports = hmModules;
              extraSpecialArgs = {
                inherit nixpkgsUnstable inputs userConfig system;
              };
              backupFileExtension = "bak";
            };
          }
        ]
        ++ extraModules;
      };
    };
}
