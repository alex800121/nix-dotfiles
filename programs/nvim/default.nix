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
          ./module.nix
        ];
        inherit pkgs;
      };
    })
  ];
}
