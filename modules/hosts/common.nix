{ inputs, self, ... }:
{
  flake.nixosConfigurations.common = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.common
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        nixpkgs.overlays = [ self.overlays.neovim ];
      }
    ];
  };
}
