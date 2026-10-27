{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgsUnstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/latest";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    # wrappers.inputs.nixpkgs.follows = "nixpkgs";
    rpi4fw = {
      url = "tarball+https://github.com/pftf/RPi4/releases/download/v1.51/RPi4_UEFI_Firmware_v1.51.zip";
      flake = false;
    };
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
    cpak.url = "github:Containerpak/cpak/v2";
    # cpak.inputs.nixpkgs.follows = "nixpkgs";
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
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (top: {
      imports = [
        (inputs.import-tree ./modules)
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { config, pkgs, ... }: {
        packages.goose-pl = pkgs.callPackage ./packages/goose-pl/package.nix { };
        overlayAttrs = {
          inherit (config.packages) goose-pl;
        };
      };

    });
}
