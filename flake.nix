{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    haskell-updates.url = "github:nixos/nixpkgs/haskell-updates";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # agenix = {
    #   url = "github:ryantm/agenix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , ...
    }:
    let
      mkNixosIso = (import ./utils/func.nix).mkNixosIso inputs;
      mkNixosConfig = (import ./utils/func.nix).mkNixosConfig inputs;
      config = import ./configuration/config.nix;
      outputConfigs = nixpkgs.lib.attrsets.foldlAttrs (acc: name: conf: nixpkgs.lib.recursiveUpdate acc (mkNixosConfig conf name)) { } config;
      outputIso = nixpkgs.lib.attrsets.foldlAttrs (acc: name: conf: nixpkgs.lib.recursiveUpdate acc (mkNixosIso conf name)) { } config;
    in
    builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x y) { } [
      outputIso
      outputConfigs
    ];
}
