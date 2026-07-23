{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kitty-wrapped = inputs.wrappers.lib.evalPackage {
        imports = [
          self.wrapperModules.kitty-module
        ];
        configDir = ./config;
        inherit pkgs;
      };
    };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.overlays.kitty = _self: super: {
    kitty = self.packages."${super.stdenv.hostPlatform.system}".kitty-wrapped;
  };
}
