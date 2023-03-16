{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-ld.url = "github:Mic92/nix-ld";
    # nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  # outputs = inputs@{ nixpkgs, home-manager, nix-ld, ... }: {
  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      asus-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { 
              nixpkgs.overlays = [
                (import ./overlays)
              ];
            }
          )
          # nix-ld.nixosModules.nix-ld
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.alex800121 = import ./home.nix;
              backupFileExtension = "bak";
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };
}
