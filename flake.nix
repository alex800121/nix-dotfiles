{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
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
  };

  # outputs = inputs@{ nixpkgs, home-manager, nix-ld, ... }: {
  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, agenix, rust-overlay, nixpkgsUnstable, networkmanager-dmenu, ... }: let
    mkNixosConfig = { system, userConfig, extraModules ? [], extraHMModules ? [], ... }: {
      nixosConfigurations."${userConfig.hostName}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit userConfig inputs system; 
        };
        modules = [
          { 
            nixpkgs.overlays = [
              (import ./overlays/x-air-edit)
              (import ./overlays/tlp)
              (import ./overlays/nvim-web-devicons)
              rust-overlay.overlays.default
            ];
          }
          ./configuration
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userConfig.userName}" = import ./home;
              # sharedModules = extraHMModules;
              extraSpecialArgs = { 
                inherit inputs system userConfig;
                imports =  extraHMModules; 
              };
              backupFileExtension = "bak";
            };
          }
        ] ++ extraModules;
      };
    };
    asus-nixos = {
      system = "x86_64-linux";
      userConfig = {
        hostName = "asus-nixos";
        userName = "alex800121";
        fontSize = 11.5;
        autoLogin = false;
      };
      extraModules = [
        ./hardware/asus.nix
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        inputs.musnix.nixosModules.musnix
        ./programs/musnix
        # ./de/gnome
        ./de/hyprland
      ];
      extraHMModules = [
        ./programs/onedrive
        ./programs/nvim
      ];
    };
    acer-nixos = {
      system = "x86_64-linux";
      userConfig = {
        hostName = "acer-nixos";
        userName = "alex800121";
        fontSize = 16;
        autoLogin = true;
      };
      extraModules = [
        ./hardware/acer.nix
        ./de/gnome
        ./programs/revtunnel
        ./programs/nix-ld
        ./programs/code-tunnel
      ];
      extraHMModules = [
        ./programs/nvim
      ];
    };
    acer-tp = {
      system = "x86_64-linux";
      userConfig = {
        hostName = "acer-tp";
        userName = "alex800121";
        fontSize = 16;
        autoLogin = true;
      };
      extraModules = [
        ./hardware/acer-tp.nix
        ./de/gnome
        ./programs/nix-ld
        ./programs/duckdns
        ./programs/code-tunnel
      ];
      extraHMModules = [
        ./programs/nvim
      ];
    };
  in builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosConfig y)) {} [
    asus-nixos 
    acer-nixos
    acer-tp
  ];
}
