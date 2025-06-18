{ config, userConfig, lib, ... }:
{
  age.secrets.nix-common = {
    file = ../secrets/nix_common.age;
    owner = "nix-ssh";
    group = "nix-ssh";
    mode = "600";
  };
  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+ alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCwYhT26ZCYB0fSe9rAyvQdV9sz/me2V+vL9dLVWd0W root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG885XYlPfi2h6hiokfhvZgHF1y2f3JnL11j+ARJkrXE alex800121@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKH5JQY6WjU7N0Z+WYoHiej4TzhN8Prfs5uiqvXExPvm root@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYRhvHSun0BXMV1oBi93FncWVFEma5pv6fKeruccOuW alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpxrX0RcNtg/wOxeJ7SUkUEVzWUYvZk4z0Khd7fxgVd root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv15uz9Ndk+y0SZ2L64OgjLXBV8JwTDHbYca9a/oYHx alex800121@oracle"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHudmbpZMo5vJ4m2WxV3dyw9BTapuoN6AdTnfZuugo99 root@oracle"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn3nkUDVHY0ZDAxo6bAjMb2k5ic7G6RCDQkBOtJo8dd alex800121@oracle2"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYAa4EReVbKim6EeXqwlFB88zmajL31WWfVsvIOO1Lc root@oracle2"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGobHzAuouhLf9IXr9eJl2saxFkal+cxcTAWP8EYo+Zl alex800121@oracle3"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVrCm9KX83d8Uv46MZ8aYm7frR9zuQwuK9opRB9/HZt root@oracle3"
  ];
  nix.sshServe.write = true;
  nix.sshServe.trusted = true;

  nix.extraOptions = ''
    secret-key-files = ${config.age.secrets.nix-common.path}
    builders-use-substitutes = true
  '';

}
