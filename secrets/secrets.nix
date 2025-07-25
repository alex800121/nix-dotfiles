let
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYRhvHSun0BXMV1oBi93FncWVFEma5pv6fKeruccOuW";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzMKvJj6q/7kBnBwmVbihs23csYbDS27kFOvtZDLYzB";
  acer-tp = [ acer-tp-user acer-tp-system ];
  alexrpi4tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+";
  alexrpi4tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHt5Lm+fw93lILN2r82qTb/XieIrVrD/fbLio2G4tHqy";
  alexrpi4tp = [ alexrpi4tp-user alexrpi4tp-system ];
  fw13-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG885XYlPfi2h6hiokfhvZgHF1y2f3JnL11j+ARJkrXE";
  fw13-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQNzT1Bg7s93u10Keu/wZ7oJ8EynEZnSQAK712KQAkv";
  fw13 = [ fw13-user fw13-system ];
  oracle-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv15uz9Ndk+y0SZ2L64OgjLXBV8JwTDHbYca9a/oYHx";
  oracle-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAmj2g3azH1O+1a1p8CK6csf1vSILXrLoHS5srPvFA2";
  oracle = [ oracle-user oracle-system ];
  oracle2-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn3nkUDVHY0ZDAxo6bAjMb2k5ic7G6RCDQkBOtJo8dd";
  oracle2-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvDQec6+LCW0+KHPGwIAofQEalfPNa7M5gUsPBIAfnM";
  oracle2 = [ oracle2-user oracle2-system ];
  oracle3-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGobHzAuouhLf9IXr9eJl2saxFkal+cxcTAWP8EYo+Zl";
  oracle3-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1xdQ/DG5W62vO+cJZTEhiOd0V2N9CBqwhnd3xA4Vqj";
  oracle3 = [ oracle3-user oracle3-system ];
in
{
  "ssh_host_borgbackup_acer-tp_vaultwarden_db_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_acer-tp_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_acer-tp_vaultwarden_db_oracle.age".publicKeys = oracle;
  "ssh_host_borgbackup_acer-tp_vaultwarden_oracle.age".publicKeys = oracle;
  "passphrase_borgbackup_vaultwarden.age".publicKeys = alexrpi4tp ++ oracle;
  "env_vaultwarden.age".publicKeys = alexrpi4tp ++ oracle ++ oracle2 ++ oracle3 ++ acer-tp ++ fw13;
  "ddtoken.age".publicKeys =alexrpi4tp ++ oracle ++ oracle2 ++ oracle3 ++ acer-tp ++ fw13; 
  "tsapi.age".publicKeys = alexrpi4tp ++ oracle ++ oracle2 ++ oracle3 ++ acer-tp ++ fw13;
  "tsauth.age".publicKeys = alexrpi4tp ++ oracle ++ oracle2 ++ oracle3 ++ acer-tp ++ fw13;
  "nix_common.age".publicKeys = alexrpi4tp ++ oracle ++ oracle2 ++ oracle3 ++ acer-tp ++ fw13;
}
