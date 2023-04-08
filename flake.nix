{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsStable.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # outputs = inputs@{ nixpkgs, home-manager, nix-ld, ... }: {
  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, ... }: {
    nixosConfigurations = {
      asus-nixos = let 
        system = "x86_64-linux";
        userName = "alex800121";
        hostName = "asus-nixos";
        userConfig = {
          fontSize = 11.5;
        };
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hostName userName; };
        modules = [
          { 
            nixpkgs.overlays = [
              (import ./overlays)
            ];
          }
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          ./configuration.nix
          ./hardware_config/asus.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userName}" = import ./home.nix;
              sharedModules = [
                ./programs/onedrive
              ];
              extraSpecialArgs = { inherit inputs system userName userConfig; };
              backupFileExtension = "bak";
            };
          }
        ];
      };
      acer-nixos = let
        system = "x86_64-linux";
        hostName = "acer-nixos";
        userName = "alex800121";
        userConfig = {
          fontSize = 16;
        };
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hostName userName; };
        modules = [
          { 
            nixpkgs.overlays = [
              (import ./overlays)
            ];
          }
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          ./configuration.nix
          ./hardware_config/acer.nix
          ./programs/nix-ld
          ./programs/revtunnel
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userName}" = import ./home.nix;
              extraSpecialArgs = { inherit inputs system userName userConfig; };
              backupFileExtension = "bak";
            };
          }
        ];
      };
    };
  };
}