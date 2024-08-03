{ lib, userConfig, config, ... }:
let
  inherit (userConfig) hostName;
in
{
  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaSD3qsWtMBdadX2256X+2xBl4O3//d/vGUKBxgCTyR root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICF22WQW3bhm7MpPR9Ye3SFDudNJ6XdXgEqSIrE7Cv33 root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRfzBZZwaxAMXgzBpj8Zp3g5KFaPzLbgQgu12sOzRRB alex800121@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFKci4KwY1pL5NiuiKOdc5q/TUoi/CUrVxdTkx0QOS4x root@fw13"
  ];
  nix.distributedBuilds = true;
  nix.settings.trusted-users = [ "nix-ssh" "alex800121" "@wheel" ];
  nix.settings.trusted-public-keys = [
    "nix-alexrpi4tp:XZMMtcMyPm9a8/hV7Dp8Z27hlUYp+jPg7uSBDTY+X4Y="
    "nix-acer-tp:POOYVdWQp5avm9ZWd65SVcLdYiMNNx7Pfq/GtHr5WUc="
    "nix-fw13:/TV9laUNWT/D7NcIVqgAzqckMV9v69Sp13B/cu7hwBY="
  ];
  age.secrets."nix-${hostName}" = {
    file = ../secrets/nix-${hostName}.age;
    owner = "nix-ssh";
    group = "nix-ssh";
    mode = "600";
  };
  nix.extraOptions = ''
    secret-key-files = ${config.age.secrets."nix-${hostName}".path}
    builders-use-substitutes = true
  '';
  nix.buildMachines = lib.filter (x: x.hostName != hostName)
    [
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
