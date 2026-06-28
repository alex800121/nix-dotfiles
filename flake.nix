{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      mkNixosIso = (import ./utils/func.nix).mkNixosIso inputs;
      mkNixosConfig = (import ./utils/func.nix).mkNixosConfig inputs;
      config = import ./configuration/config.nix;
    in
    {
      nixosConfigurations.fw13 = mkNixosConfig config.fw13;
      nixosConfigurations.fw13-musnix = mkNixosConfig config.fw13-musnix;
      nixosConfigurations.acer-tp = mkNixosConfig config.acer-tp;
      nixosConfigurations.oracle = mkNixosConfig config.oracle;
      nixosConfigurations.oracle2 = mkNixosConfig config.oracle2;
      nixosConfigurations.oracle3 = mkNixosConfig config.oracle3;
      nixosConfigurations.alexrpi4tp = mkNixosConfig config.alexrpi4tp;
      nixosConfigurations.alexrpi4tpmin = mkNixosIso config.alexrpi4tpmin;
    };
}
