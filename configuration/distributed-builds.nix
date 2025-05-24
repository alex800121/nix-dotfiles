{ lib, userConfig, config, ... }:
let
  inherit (userConfig) hostName;
  setCred = "nix.key:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../secrets/nix-${userConfig.hostName}));
in
{
  nix.distributedBuilds = true;

  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCwYhT26ZCYB0fSe9rAyvQdV9sz/me2V+vL9dLVWd0W root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+ alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG885XYlPfi2h6hiokfhvZgHF1y2f3JnL11j+ARJkrXE alex800121@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKH5JQY6WjU7N0Z+WYoHiej4TzhN8Prfs5uiqvXExPvm root@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYRhvHSun0BXMV1oBi93FncWVFEma5pv6fKeruccOuW alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpxrX0RcNtg/wOxeJ7SUkUEVzWUYvZk4z0Khd7fxgVd root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv15uz9Ndk+y0SZ2L64OgjLXBV8JwTDHbYca9a/oYHx alex800121@oracle"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAmj2g3azH1O+1a1p8CK6csf1vSILXrLoHS5srPvFA2 root@oracle"
  ];

  nix.settings.substituters = [ "https://nix-community.cachix.org" ];
  nix.settings.trusted-substituters = [ "https://nix-community.cachix.org" ];
  nix.settings.trusted-users = [ "nix-ssh" "alex800121" "@wheel" ];
  nix.settings.trusted-public-keys = [
    "nix-acer-tp:POOYVdWQp5avm9ZWd65SVcLdYiMNNx7Pfq/GtHr5WUc="
    "nix-fw13:yQd04YEg7RVa2KMfA8HtgYvTmki5BU0dVbJrRCLuEoU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nix-alexrpi4tp:VvDq2N5Uq0wxLD1s78xD7odwk9zCSt8dqu6cdP5n8ws="
    "nix-oracle:LzSqFMTgbYSaQ7+UKD7FmyclOi/iwh7GqVcyuETKsV0="
  ];

  # age.secrets."nix-${hostName}" = {
  #   file = ../secrets/nix-${hostName}.age;
  #   owner = "nix-ssh";
  #   group = "nix-ssh";
  #   mode = "600";
  # };

  systemd.services.nix-daemon.serviceConfig.SetCredentialEncrypted = setCred;

  nix.extraOptions = ''
    secret-key-files = /run/credentials/nix-daemon.service/nix.key
    builders-use-substitutes = true
  '';

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
