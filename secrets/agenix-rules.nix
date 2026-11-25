let
  all = alexrpi4tp ++ oracle ++ oracle2 ++ oracle3 ++ oracle4 ++ acer-tp ++ fw13 ++ fw12;
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYRhvHSun0BXMV1oBi93FncWVFEma5pv6fKeruccOuW";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzMKvJj6q/7kBnBwmVbihs23csYbDS27kFOvtZDLYzB";
  acer-tp = [
    acer-tp-user
    acer-tp-system
  ];
  alexrpi4tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+";
  alexrpi4tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHt5Lm+fw93lILN2r82qTb/XieIrVrD/fbLio2G4tHqy";
  alexrpi4tp = [
    alexrpi4tp-user
    alexrpi4tp-system
  ];
  fw12-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3uLM6LKLkIh9pZD6ibhG0eu2An+wCrAzlhpb5+0Meg";
  fw12-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOx6BpYKOxtL6t+xfddXD/mVmP/EQGE1zd+5anOjagb3";
  fw12 = [
    fw12-user
    fw12-system
  ];
  fw13-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG885XYlPfi2h6hiokfhvZgHF1y2f3JnL11j+ARJkrXE";
  fw13-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQNzT1Bg7s93u10Keu/wZ7oJ8EynEZnSQAK712KQAkv";
  fw13 = [
    fw13-user
    fw13-system
  ];
  oracle-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv15uz9Ndk+y0SZ2L64OgjLXBV8JwTDHbYca9a/oYHx";
  oracle-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAmj2g3azH1O+1a1p8CK6csf1vSILXrLoHS5srPvFA2";
  oracle = [
    oracle-user
    oracle-system
  ];
  oracle2-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn3nkUDVHY0ZDAxo6bAjMb2k5ic7G6RCDQkBOtJo8dd";
  oracle2-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvDQec6+LCW0+KHPGwIAofQEalfPNa7M5gUsPBIAfnM";
  oracle2 = [
    oracle2-user
    oracle2-system
  ];
  oracle3-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGobHzAuouhLf9IXr9eJl2saxFkal+cxcTAWP8EYo+Zl";
  oracle3-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1xdQ/DG5W62vO+cJZTEhiOd0V2N9CBqwhnd3xA4Vqj";
  oracle3 = [
    oracle3-user
    oracle3-system
  ];
  oracle4-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZwJjOboE/KvYqtb9Ecmnotn/hOd4Zv7goI8d+6tCYD";
  oracle4-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICk6UXDj18/taby2f3L4LVZTH76/XbII96oZtdv50lmM";
  oracle4 = [
    oracle4-user
    oracle4-system
  ];
in
{
  "ssh_host_borgbackup_acer-tp_vaultwarden_db_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_acer-tp_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_acer-tp_vaultwarden_db_oracle.age".publicKeys = oracle;
  "ssh_host_borgbackup_acer-tp_vaultwarden_oracle.age".publicKeys = oracle;
  "passphrase_borgbackup_vaultwarden.age".publicKeys = alexrpi4tp ++ oracle;
  "env_vaultwarden.age".publicKeys = all;
  "ddtoken.age".publicKeys = all;
  "tsapi.age".publicKeys = all;
  "tsauth.age".publicKeys = all;
  "tsid.age".publicKeys = all;
  "tssecret.age".publicKeys = all;
  "nix_common.age".publicKeys = all;
  "cloudflare.age".publicKeys = all;
  "cloudflare-inadyn.age".publicKeys = all;
  "cloudflare-r2.age".publicKeys = all;
  "syncthing/key-alexrpi4tp.age".publicKeys = fw13 ++ alexrpi4tp;
  "syncthing/key-fw13.age".publicKeys = fw13;
  "syncthing/key-oracle.age".publicKeys = fw13 ++ oracle;
  "syncthing/key-oracle4.age".publicKeys = fw13 ++ oracle4;
  "syncthing/key-fw12.age".publicKeys = fw13 ++ fw12;
  "syncthing/cert-alexrpi4tp.age".publicKeys = fw13 ++ alexrpi4tp;
  "syncthing/cert-fw13.age".publicKeys = fw13;
  "syncthing/cert-oracle.age".publicKeys = fw13 ++ oracle;
  "syncthing/cert-oracle4.age".publicKeys = fw13 ++ oracle4;
  "syncthing/cert-fw12.age".publicKeys = fw13 ++ fw12;
  "syncthing/pw.age".publicKeys = all;
  "awg/header.age".publicKeys = all;
  "awg/oracle.age".publicKeys = all;
  "awg/oracle2.age".publicKeys = all;
  "awg/oracle3.age".publicKeys = all;
  "awg/oracle4.age".publicKeys = all;
  "awg/alexrpi4tp.age".publicKeys = all;
  "awg/acer-tp.age".publicKeys = all;
  "awg/fw13.age".publicKeys = all;
  "awg/fw12.age".publicKeys = all;
  "awg/pixel7a.age".publicKeys = all;
  "awg/conf-oracle.age".publicKeys = all;
  "awg/conf-alexrpi4tp.age".publicKeys = all;
  "awg/conf-fw13.age".publicKeys = all;
  "awg/conf-pixel7a.age".publicKeys = all;
  "xray-server-oracle.age".publicKeys = fw13 ++ oracle;
  "xray-client-fw13.age".publicKeys = fw13 ++ oracle;
}
