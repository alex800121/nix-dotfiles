{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsStable.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      acer-nixos = let
        system = "x86_64-linux";
        hostName = "acer-nixos";
        userName = "alex800121";
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hostName userName; };
        modules = [
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
              backupFileExtension = "bak";
              extraSpecialArgs = {
                inherit inputs userName;
              };
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };
}
