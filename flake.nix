{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    haskell-updates.url = "github:nixos/nixpkgs/haskell-updates";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , nixos-hardware
    , agenix
    , rust-overlay
    , nixpkgsUnstable
    , ...
    }:
    let
      mkSdImage = { inputModule, ... }: {
        image."${inputModule._module.specialArgs.userConfig.hostName}" = (inputModule.extendModules {
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ({ ... }: {
              config = {
                sdImage.compressImage = false;
                users.users."root".initialPassword = "root";
              };
            })
            {
              nixpkgs.overlays = [
                (final: super: {
                  makeModulesClosure = x:
                    super.makeModulesClosure (x // { allowMissing = true; });
                })
              ];
            }
          ];
        }).config.system.build.sdImage;
      };
      mkNixosConfig = { system, userConfig, extraModules ? [ ], hmModules ? [ ], kernelVersion, overlays ? [ ], ... }: configName:
        let
          nixpkgs-unstable = import inputs.nixpkgsUnstable {
            inherit system overlays;
            config.allowUnfree = true;
          };
        in
        {
          nixosConfigurations."${configName}" = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit kernelVersion userConfig inputs extraModules hmModules;
              nixpkgsUnstable = nixpkgs-unstable;
            };
            modules = [
              ./configuration/distributed-builds.nix
              {
                nixpkgs.config.allowUnsupportedSystem = true;
                nixpkgs.overlays = [
                  rust-overlay.overlays.default
                ];
              }
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
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
      configs = {
        rpi4 = {
          system = "aarch64-linux";
          kernelVersion = "rpi4";
          userConfig = {
            hostName = "rpi4";
            userName = "alex800121";
            fontSize = 11.5;
            autoLogin = true;
          };
          extraModules = [
            ./configuration/rpi4sd.nix
            ./hardware/rpi4.nix
            nixos-hardware.nixosModules.raspberry-pi-4
            ./programs/sshd
          ];
          hmModules = [
            ./home/rpi4sd.nix
          ];
        };
        alexrpi4tp = {
          system = "aarch64-linux";
          kernelVersion = "rpi4";
          userConfig = {
            hostName = "alexrpi4tp";
            userName = "alex800121";
            fontSize = 11.5;
            autoLogin = true;
            url = "alexrpi4gate";
            port = "30000";
          };
          extraModules = [
            ./configuration/rpi4.nix
            ./hardware/rpi4.nix
            nixos-hardware.nixosModules.raspberry-pi-4
            ./programs/sshd
            ./programs/duckdns
          ];
          hmModules = [
            ./home/rpi4.nix
            ./programs/nvim
          ];
        };
        acer-tp = {
          system = "x86_64-linux";
          kernelVersion = "6_10";
          userConfig = {
            hostName = "acer-tp";
            userName = "alex800121";
            fontSize = 16;
            autoLogin = true;
            url = "alexacer-tp";
            port = "31000";
          };
          extraModules = [
            ./configuration
            ./hardware/acer-tp.nix
            ./hardware/desktop.nix
            ./de/gnome
            ./programs/nix-ld
            ./programs/duckdns
            ./programs/code-tunnel
            ./programs/wireguard/acer-tp.nix
            ./programs/sshd
            ./programs/virt
          ];
          hmModules = [
            ./home
            ./programs/nvim
          ];
        };
      };
      outputConfigs = builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosConfig configs."${y}" y)) { } [
        "acer-tp"
        "alexrpi4tp"
      ];
    in
    builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x y) { } [
      (mkSdImage { inputModule = (mkNixosConfig configs.rpi4 "rpi4").nixosConfigurations.rpi4; })
      (mkSdImage { inputModule = outputConfigs.nixosConfigurations.alexrpi4tp; })
      outputConfigs
    ];
}
