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
      nixpkgs2505 = import inputs.nixpkgs2505 {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."${configName}" = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nixpkgs2505 nixpkgsUnstable conf userConfig inputs extraModules hmModules;
        };
        modules = [
          {
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
              (self: super: {
                haskell = super.haskell // {
                  packages = super.haskell.packages // {
                    ghc9122 = super.haskell.packages.ghc9122.override {
                      overrides = hself: hsuper:
                        let
                          oScope = cself: csuper: {
                            Cabal-syntax = cself.Cabal-syntax_3_14_2_0;
                            Cabal = cself.Cabal_3_14_2_0;
                          };
                          cabal-install = hsuper.cabal-install.overrideScope oScope;
                          cabal-install-solver = hsuper.cabal-install-solver.overrideScope oScope;
                        in
                        {
                          cabal-install-solver = super.haskell.lib.overrideCabal
                            cabal-install-solver
                            (drv: {
                              version = "3.14.2.0";
                              revision = "0";
                              sha256 = "sha256-4R0XF/VPdYUkWFm7LIMFq0lOP7sH+zWaxE7aNfNmoRQ=";
                            });
                          cabal-install = super.haskell.lib.overrideCabal
                            cabal-install
                            (drv: {
                              version = "3.14.2.0";
                              revision = "3";
                              sha256 = "1nvv3h9kq92ifyqqma88538579v7898pd9b52hras2h489skv8g8";
                              editedCabalFile = "sha256-8COFdH/TBkcbIm3iqNQcKASYCxsbdtXMqCPkpGwaRf0=";
                              libraryHaskellDepends = [ hself.lukko ] ++ drv.libraryHaskellDepends;
                            });
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
                inherit nixpkgs2505 nixpkgsUnstable inputs userConfig system;
              };
              backupFileExtension = "bak";
            };
          }
        ]
        ++ extraModules;
      };
    };
}
