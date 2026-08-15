{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.zellij-wrapped = inputs.wrappers.lib.evalPackage {
        imports = [
          self.wrapperModules.zellij-module
        ];
        programs.zellij.configFile = ./config.kdl;
        inherit pkgs;
      };
    };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.overlays.zellij = _self: super: {
    zellij = self.packages."${super.stdenv.hostPlatform.system}".zellij-wrapped;
  };
}
