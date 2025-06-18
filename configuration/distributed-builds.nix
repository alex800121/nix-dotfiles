{ lib, userConfig, ... }:
let
  inherit (userConfig) hostName;
in
{
  nix.distributedBuilds = true;

  nix.settings.substituters = [ "https://nix-community.cachix.org" ];
  nix.settings.trusted-substituters = [ "https://nix-community.cachix.org" ];
  nix.settings.trusted-users = [ "nix-ssh" "alex800121" "@wheel" ];
  nix.settings.trusted-public-keys = [
    "nix-common:tfkDg1lt8EUsog/Gex0wLDW61jqUslDg9nevljQ6aKM="
  ];

  nix.buildMachines = lib.filter (x: x.hostName != hostName)
    [
      {
        hostName = "oracle";
        sshUser = "alex800121";
        systems = [ "aarch64-linux" ];
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
        maxJobs = 2;
      }
      {
        hostName = "alexrpi4tp";
        sshUser = "alex800121";
        systems = [ "aarch64-linux" ];
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
        maxJobs = 4;
      }
      {
        hostName = "acer-tp";
        sshUser = "alex800121";
        systems = [ "x86_64-linux" "aarch64-linux" ];
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        maxJobs = 4;
      }
    ];
}
