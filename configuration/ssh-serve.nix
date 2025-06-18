{ userConfig, lib, ... }:
let
  setCred = "nix.key:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../secrets/nix-${userConfig.hostName}));
in
{
  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCwYhT26ZCYB0fSe9rAyvQdV9sz/me2V+vL9dLVWd0W root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+ alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG885XYlPfi2h6hiokfhvZgHF1y2f3JnL11j+ARJkrXE alex800121@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKH5JQY6WjU7N0Z+WYoHiej4TzhN8Prfs5uiqvXExPvm root@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYRhvHSun0BXMV1oBi93FncWVFEma5pv6fKeruccOuW alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpxrX0RcNtg/wOxeJ7SUkUEVzWUYvZk4z0Khd7fxgVd root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv15uz9Ndk+y0SZ2L64OgjLXBV8JwTDHbYca9a/oYHx alex800121@oracle"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHudmbpZMo5vJ4m2WxV3dyw9BTapuoN6AdTnfZuugo99 root@oracle"
  ];
  nix.sshServe.write = true;
  nix.sshServe.trusted = true;

  nix.extraOptions = ''
    secret-key-files = /run/credentials/nix-daemon.service/nix.key
    builders-use-substitutes = true
  '';

  # age.secrets."nix-${hostName}" = {
  #   file = ../secrets/nix-${hostName}.age;
  #   owner = "nix-ssh";
  #   group = "nix-ssh";
  #   mode = "600";
  # };

  systemd.services.nix-daemon.serviceConfig.SetCredentialEncrypted = setCred;

}
