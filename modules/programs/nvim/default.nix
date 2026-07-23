{
  inputs,
  self,
  ...
}:
{
  flake.overlays.neovim-min = _self: super: {
    neovim = self.packages."${super.stdenv.hostPlatform.system}".neovim-min-wrapped;
  };
  flake.overlays.neovim = _self: super: {
    neovim = self.packages."${super.stdenv.hostPlatform.system}".neovim-wrapped;
  };
  perSystem =
    { pkgs, ... }:
    {
      packages.neovim-min-wrapped = inputs.wrappers.lib.evalPackage {
        imports = [
          self.wrapperModules.neovim-min-module
        ];
        inherit pkgs;
      };
      packages.neovim-wrapped = inputs.wrappers.lib.evalPackage {
        imports = [
          self.wrapperModules.neovim-module
        ];
        inherit pkgs;
      };
    };
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
