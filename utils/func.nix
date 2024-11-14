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
          userConfig = {
            userName = "root";
            port = 22;
          };
        };
      };
  };
  mkNixosConfig =
    inputs:
    { system, userConfig, extraModules ? [ ], hmModules ? [ ], kernelVersion, overlays ? [ ], ... }:
    configName:
    let
      nixpkgs-unstable = import inputs.nixpkgsUnstable {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."${configName}" = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit kernelVersion userConfig inputs extraModules hmModules;
          nixpkgsUnstable = nixpkgs-unstable;
        };
        modules = [
          {
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
              (import ../overlay/google-chrome.nix)
            ];
          }
          # agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userConfig.userName}".imports = hmModules;
              extraSpecialArgs = {
                inherit inputs userConfig system;
                nixpkgsUnstable = nixpkgs-unstable;
              };
              backupFileExtension = "bak";
            };
          }
        ]
        ++ extraModules;
      };
    };
}
