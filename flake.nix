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
    , home-manager
    , nixos-hardware
    , musnix
    , rust-overlay
    , nixpkgsUnstable
    , lanzaboote
    , ...
    }:
    let
      mkNixosIso = (import ./utils/func.nix).mkNixosIso inputs;
      mkNixosConfig = (import ./utils/func.nix).mkNixosConfig inputs;
      configs = {
        alexrpi4tpmin = {
          system = "aarch64-linux";
          kernelVersion = "rpi4";
          userConfig = {
            hostName = "alexrpi4tp";
            userName = "alex800121";
            fontSize = 11.5;
            autoLogin = true;
          };
          extraModules = [
            ./configuration/alexrpi4tpmin.nix
          ];
          hmModules = [
            ./home/rpi4.nix
          ];
        };
        alexrpi4tp = {
          system = "aarch64-linux";
          kernelVersion = "rpi4";
          userConfig = {
            hostName = "alexrpi4tp";
            userName = "alex800121";
            fontSize = 11.5;
            autoLogin = true;
            url = "alexrpi4gate";
            port = 30000;
          };
          extraModules = [
            ./configuration/alexrpi4tp.nix
          ];
          hmModules = [
            ./home/rpi4.nix
            ./programs/nvim
          ];
        };
        acer-tp = {
          system = "x86_64-linux";
          kernelVersion = "6_11";
          userConfig = {
            hostName = "acer-tp";
            userName = "alex800121";
            fontSize = 16;
            autoLogin = true;
            url = "alexacer-tp";
            port = 31000;
          };
          extraModules = [
            ./configuration/acer-tp.nix
          ];
          hmModules = [
            ./home
            ./programs/nvim
          ];
        };
        fw13 = {
          system = "x86_64-linux";
          kernelVersion = "6_12";
          userConfig = {
            hostName = "fw13";
            userName = "alex800121";
            fontSize = 12;
            autoLogin = false;
            port = 32000;
            soundcardPciId = "c1:00.6";
          };
          extraModules = [
            ./configuration/fw13.nix
          ];
          hmModules = [
            ./home
            ./programs/nvim
          ];
        };
      };
      outputConfigs = builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosConfig configs."${y}" y)) { } [
        "acer-tp"
        "alexrpi4tp"
        "fw13"
        "alexrpi4tpmin"
      ];
      outputIso = builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x (mkNixosIso configs."${y}" y)) { } [
        "fw13"
      ];
    in
    builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x y) { } [
      outputIso
      outputConfigs
    ];
}
