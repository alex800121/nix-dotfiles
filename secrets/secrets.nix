let
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8QIkayntlJgarKb0rt5fy+413SfARjxszlE8tut4HB";
  acer-tp = [ acer-tp-user acer-tp-system ];
  alexrpi4tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM";
  alexrpi4tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYWWE+KePNOcBGSoBABUP8dZcUvJbWLGZtaoG0mrIeW";
  alexrpi4tp = [ alexrpi4tp-user alexrpi4tp-system ];
  fw13-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMraRiOlQzoow7HBhsDh+HQKrh5tddB1wB8MIMaw0kf";
  fw13-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0Vv4anN/LjTy5lwcUTXXW7v2Xm9x1jzKU+c6S0ewxA";
  fw13 = [fw13-user fw13-system];
in
{
  "ddtoken-alexrpi4tp.age".publicKeys = alexrpi4tp;
  "nix-acer-tp.age".publicKeys = acer-tp;
  "nix-alexrpi4tp.age".publicKeys = alexrpi4tp;
  "nix-fw13.age".publicKeys = fw13;
  "wg-acer-tp.age".publicKeys = acer-tp;
  "wg-fw13.age".publicKeys = fw13;
  "google-geoloc-acer-tp.age".publicKeys = acer-tp;
  "google-geoloc-fw13.age".publicKeys = fw13;
}
