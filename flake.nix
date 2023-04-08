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
    mkNixosConfig = { system, userConfig, extraModules ? [], ... }: {
      nixosConfigurations."${userConfig.hostName}" = let
        inherit system;
        inherit userConfig;
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit userConfig; };
        modules = [
          { 
            nixpkgs.overlays = [
              (import ./overlays)
            ];
          }
          
          ./configuration.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${userConfig.userName}" = import ./home.nix;
              sharedModules = [
                ./programs/onedrive
              ];
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
        nixos-hardware.nixosModules.common-cpu-amd-pstate
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
      ];
    };
  in builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosConfig y)) {} [ asus-nixos acer-nixos ];
}
