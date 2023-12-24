{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    networkmanager-dmenu = {
      url = "github:firecat53/networkmanager-dmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haskell-snippets = {
      url = "github:mrcjkb/haskell-snippets.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, agenix, rust-overlay, nixpkgsUnstable, networkmanager-dmenu, ... }: let
    mkNixosConfig = { system, userConfig, extraModules ? [], hmModules ? [], kernelVersion, ... }: {
      nixosConfigurations."${userConfig.hostName}" = nixpkgs.lib.nixosSystem {
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
              # (import ./overlays/libfprint-2-tod1-goodix)
              rust-overlay.overlays.default
              (self: super: {
                networkmanager_dmenu = networkmanager-dmenu.packages."${system}".default;
              })
              (self: super: let
                pkgs = import nixpkgsUnstable { inherit system; };
              in {
                libsForQt5 = super.libsForQt5 // {
                  sddm = pkgs.libsForQt5.sddm;
                };
              })
              inputs.haskell-snippets.overlays.default
            ];
          }
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager {
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
    alexrpi4dorm = {
      system = "aarch64-linux";
      kernelVersion = "rpi4";
      userConfig = {
        hostName = "alexrpi4dorm";
        userName = "alex800121";
        fontSize = 11.5;
        autoLogin = true;
      };
      extraModules = [
        ./configuration/rpi4.nix
        nixos-hardware.nixosModules.raspberry-pi-4
      ];
      hmModules = [
        ./home/rpi4.nix
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
        inputs.musnix.nixosModules.musnix
        ./programs/musnix
        ./programs/winvirt
        ./de/gnome
        # ./de/hyprland
        ./hardware/asus/single-partition-passthrough.nix
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
      };
      extraModules = [
        ./configuration
        ./hardware/acer.nix
        ./hardware/desktop.nix
        ./de/gnome
        ./programs/revtunnel
        ./programs/nix-ld
        ./programs/code-tunnel
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
      };
      extraModules = [
        ./configuration
        ./hardware/acer-tp.nix
        ./hardware/desktop.nix
        ./de/gnome
        ./programs/nix-ld
        ./programs/duckdns
        ./programs/code-tunnel
        ./programs/wireguard
      ];
      hmModules = [
        ./home
        ./programs/nvim
      ];
    };
  in builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosConfig y)) {} [
    asus-nixos 
    acer-nixos
    acer-tp
    alexrpi4dorm
  ];
}
