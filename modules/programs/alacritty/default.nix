{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.alacritty-wrapped = inputs.wrappers.lib.evalPackage {
        imports = [
          self.wrapperModules.alacritty-module
        ];
        configDir = ./config;
        inherit pkgs;
      };
    };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.overlays.alacritty = _self: super: {
    alacritty = self.packages."${super.stdenv.hostPlatform.system}".alacritty-wrapped;
  };
}
