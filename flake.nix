{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/latest";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
    inputs:
    let
      mkNixosIso = (import ./utils/func.nix).mkNixosIso inputs;
      mkNixosConfig = (import ./utils/func.nix).mkNixosConfig inputs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (top: {
      imports = [ (inputs.import-tree ./modules) ];
      flake = {
        nixosConfigurations.fw13 = mkNixosConfig [ configuration/fw13.nix ];
        nixosConfigurations.fw13-musnix = mkNixosConfig [ configuration/fw13-musnix.nix ];
        nixosConfigurations.acer-tp = mkNixosConfig [ configuration/acer-tp.nix ];
        nixosConfigurations.oracle = mkNixosConfig [ configuration/oracle.nix ];
        nixosConfigurations.oracle2 = mkNixosConfig [ configuration/oracle2.nix ];
        nixosConfigurations.oracle3 = mkNixosConfig [ configuration/oracle3.nix ];
        nixosConfigurations.alexrpi4tp = mkNixosConfig [ configuration/alexrpi4tp.nix ];
        nixosConfigurations.alexrpi4tpmin = mkNixosConfig [ configuration/alexrpi4tpmin.nix ];
      };
    });
}
