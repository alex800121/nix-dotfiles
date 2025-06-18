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
    "nix-acer-tp:POOYVdWQp5avm9ZWd65SVcLdYiMNNx7Pfq/GtHr5WUc="
    "nix-fw13:yQd04YEg7RVa2KMfA8HtgYvTmki5BU0dVbJrRCLuEoU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nix-alexrpi4tp:VvDq2N5Uq0wxLD1s78xD7odwk9zCSt8dqu6cdP5n8ws="
    "nix-oracle:LzSqFMTgbYSaQ7+UKD7FmyclOi/iwh7GqVcyuETKsV0="
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
