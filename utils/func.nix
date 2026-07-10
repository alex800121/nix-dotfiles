{
  mkNixosIso =
    inputs:
    _extraModules:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        ../configuration/common.nix
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
      specialArgs = {
        inherit inputs;
      };
    };
  mkNixosConfig =
    inputs:
    extraModules:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = extraModules;
    };
}
