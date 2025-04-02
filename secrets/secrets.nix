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
in
{
  "ssh_host_borgbackup_acer-tp_vaultwarden_db_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_oracle_vaultwarden_db_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_acer-tp_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_oracle_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "passphrase_borgbackup_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "env_vaultwarden_oracle.age".publicKeys = oracle;
  "env_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "env_vaultwarden_acer-tp.age".publicKeys = acer-tp;
  "env_vaultwarden_fw13.age".publicKeys = fw13;
  "ddtoken_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ddtoken_oracle.age".publicKeys = oracle;
  "ddtoken_acer-tp.age".publicKeys = acer-tp;
  "ddtoken_fw13.age".publicKeys = fw13;
  "tsapi_acer-tp.age".publicKeys = acer-tp;
  "tsapi_fw13.age".publicKeys = fw13;
}
