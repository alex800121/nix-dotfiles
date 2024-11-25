{
  mkNixosIso = inputs: conf: configName: {
    nixosConfigurations."${configName}-iso" = inputs.nixpkgs.lib.nixosSystem
      {
        inherit (conf) system;
        modules = [
          ../configuration/minimal.nix
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
    conf@{ system, userConfig, extraModules ? [ ], hmModules ? [ ], overlays ? [ ], overlaysUnstable ? [], ... }:
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
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
              (import ../overlay/google-chrome.nix)
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
