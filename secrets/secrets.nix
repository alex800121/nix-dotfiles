let
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8QIkayntlJgarKb0rt5fy+413SfARjxszlE8tut4HB";
  acer-tp = [ acer-tp-user acer-tp-system ];
  alexrpi4tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN61RwZQS17DGsNh0qV6OpZBQ2569cCyXY38G4T2Vc+";
  alexrpi4tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHt5Lm+fw93lILN2r82qTb/XieIrVrD/fbLio2G4tHqy";
  alexrpi4tp = [ alexrpi4tp-user alexrpi4tp-system ];
  fw13-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMraRiOlQzoow7HBhsDh+HQKrh5tddB1wB8MIMaw0kf";
  fw13-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0Vv4anN/LjTy5lwcUTXXW7v2Xm9x1jzKU+c6S0ewxA";
  fw13 = [ fw13-user fw13-system ];
in
{ 
  "ssh_host_borgbackup_acer-tp_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ssh_host_borgbackup_oracle_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "passphrase_borgbackup_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "env_vaultwarden_alexrpi4tp.age".publicKeys = alexrpi4tp;
  "ddtoken_alexrpi4tp.age".publicKeys = alexrpi4tp;
}
