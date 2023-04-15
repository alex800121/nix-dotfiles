{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsStable.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # outputs = inputs@{ nixpkgs, home-manager, nix-ld, ... }: {
  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, ... }: let
    mkNixosConfig = { system, userConfig, extraModules ? [], extraHMModules ? [], ... }: {
      nixosConfigurations."${userConfig.hostName}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit userConfig; };
        modules = [
          { 
            nixpkgs.overlays = [
              (import ./overlays/x-air-edit)
              (import ./overlays/tlp)
            ];
          }
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userConfig.userName}" = import ./home.nix;
              sharedModules = extraHMModules;
              extraSpecialArgs = { inherit inputs system userConfig; };
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
        # nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        nixos-hardware.nixosModules.common-pc-laptop-ssd
      ];
      extraHMModules = [
        ./programs/onedrive
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
        ./programs/revtunnel
        ./programs/nix-ld
      ];
    };
  in builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosConfig y)) {} [
    asus-nixos 
    acer-nixos
  ];
}
