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
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon/main";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };
    apple-firmware = {
      url = "git+file:/home/alex800121/nixos/firmware";
      flake = false;
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
    networkmanager-dmenu = {
      url = "github:firecat53/networkmanager-dmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haskell-snippets = {
      url = "github:mrcjkb/haskell-snippets.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, agenix, rust-overlay, nixpkgsUnstable, networkmanager-dmenu, ... }:
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
      mkNixosConfig = { system, userConfig, extraModules ? [ ], hmModules ? [ ], kernelVersion ? null, ... }: configName: {
        nixosConfigurations."${configName}" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit kernelVersion userConfig inputs extraModules hmModules;
          };
          modules = [
            {
              nixpkgs.overlays = [
                (import ./overlays/x-air-edit)
                (import ./overlays/microsoft-edge)
                (import ./overlays/transparent-nvim)
                (import ./overlays/scrollEOF-nvim)
                # (import ./overlays/libfprint-2-tod1-goodix)
                rust-overlay.overlays.default
                (self: super: {
                  networkmanager_dmenu = networkmanager-dmenu.packages."${system}".default;
                })
                (self: super:
                  let
                    pkgs = import nixpkgsUnstable { inherit system; };
                  in
                  {
                    libsForQt5 = super.libsForQt5 // {
                      sddm = pkgs.libsForQt5.sddm;
                    };
                  })
                inputs.haskell-snippets.overlays.default
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
                };
                backupFileExtension = "bak";
              };
            }
          ] ++ extraModules;
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
      alexrpi4dorm = {
        system = "aarch64-linux";
        kernelVersion = "rpi4";
        userConfig = {
          hostName = "alexrpi4dorm";
          userName = "alex800121";
          fontSize = 11.5;
          autoLogin = true;
          port = "50000";
          revConfig = {
            inherit (configs.alexrpi4tp.userConfig) port url;
          };
        };
        extraModules = [
          ./configuration/rpi4.nix
          ./hardware/rpi4.nix
          nixos-hardware.nixosModules.raspberry-pi-4
          ./programs/sshd
          ./programs/revtunnel
        ];
        hmModules = [
          ./home/rpi4.nix
          ./programs/nvim
        ];
      };
      musnix = {
        system = "x86_64-linux";
        kernelVersion = "6_6";
        userConfig = {
          hostName = "asus-nixos";
          userName = "alex800121";
          fontSize = 11.5;
          autoLogin = false;
        };
        extraModules = [
          ./configuration
          ./hardware/asus.nix
          ./hardware/laptop.nix
          ./hardware/amd.nix
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          inputs.musnix.nixosModules.musnix
          (import ./programs/musnix)
          ./de/gnome
          # ./de/plasma
          # ./de/hyprland
          # ./hardware/asus/single-partition-passthrough.nix
          ./programs/virt
          ./programs/sshd
        ];
        hmModules = [
          ./home
          # ./programs/onedrive
          ./programs/nvim
        ];
      };
      m1-nixos = {
        system = "aarch64-linux";
        userConfig = {
          hostName = "m1-nixos";
          userName = "alex800121";
          fontSize = 11.5;
          autoLogin = false;
        };
        extraModules = [
          ./configuration
          ./hardware/m1.nix
          ./de/gnome
          ./programs/sshd
          inputs.apple-silicon-support.nixosModules.default
	  ({...}: {
	    hardware.asahi.peripheralFirmwareDirectory = "${inputs.apple-firmware}";
	    hardware.asahi.useExperimentalGPUDriver = true;
	  })
        ];
        hmModules = [
          ./home
          ./programs/nvim
        ];
      };
      asus-nixos = {
        system = "x86_64-linux";
        kernelVersion = "6_6";
        userConfig = {
          hostName = "asus-nixos";
          userName = "alex800121";
          fontSize = 11.5;
          autoLogin = false;
        };
        extraModules = [
          ./configuration
          ./hardware/asus.nix
          ./hardware/laptop.nix
          ./hardware/amd.nix
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          # inputs.musnix.nixosModules.musnix
          # (import ./programs/musnix)
          ./programs/virt
          ./de/gnome
          # ./de/plasma
          # ./de/hyprland
          # ./hardware/asus/single-partition-passthrough.nix
          # ./programs/winvirt
          ./programs/sshd
          ./programs/wireguard/asus-nixos.nix
        ];
        hmModules = [
          ./home
          # ./programs/onedrive
          ./programs/nvim
        ];
      };
      acer-nixos = {
        system = "x86_64-linux";
        kernelVersion = "6_6";
        userConfig = {
          hostName = "acer-nixos";
          userName = "alex800121";
          fontSize = 16;
          autoLogin = true;
          port = "51000";
          revConfig = {
            inherit (configs.acer-tp.userConfig) port url;
          };
        };
        extraModules = [
          ./configuration
          ./hardware/acer.nix
          ./hardware/desktop.nix
          ./de/gnome
          ./programs/revtunnel
          ./programs/nix-ld
          ./programs/code-tunnel
          ./programs/sshd
          ./programs/virt
        ];
        hmModules = [
          ./home
          ./programs/nvim
        ];
      };
      acer-tp = {
        system = "x86_64-linux";
        kernelVersion = "6_6";
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
        "asus-nixos"
        "acer-nixos"
        "acer-tp"
        "alexrpi4dorm"
        "alexrpi4tp"
        "musnix"
        "m1-nixos"
      ];
    in
    builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x y) { } [
      (mkSdImage { inputModule = (mkNixosConfig configs.rpi4 "rpi4").nixosConfigurations.rpi4; })
      (mkSdImage { inputModule = outputConfigs.nixosConfigurations.alexrpi4tp; })
      (mkSdImage { inputModule = outputConfigs.nixosConfigurations.alexrpi4dorm; })
      outputConfigs
    ];
}
