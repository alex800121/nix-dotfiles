{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (self: super: {
      neovim = inputs.wrappers.lib.evalPackage {
        imports = [
          ./module-min.nix
        ];
        inherit pkgs;
      };
    })
  ];
}
