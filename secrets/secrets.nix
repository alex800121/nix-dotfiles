let
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8QIkayntlJgarKb0rt5fy+413SfARjxszlE8tut4HB";
  acer-tp = [ acer-tp-user acer-tp-system ];
  acer-nixos-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEydwYcKvthPPxPt4P7YkzUgzHahKk/gAMUv7py/jeCN";
  acer-nixos-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL40ujSOBE4Nh6scsVCJv69893a+rfa2m9SDrAxfWG5P";
  acer-nixos = [ acer-nixos-user acer-nixos-system ];
  alexrpi4tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM";
  alexrpi4tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYWWE+KePNOcBGSoBABUP8dZcUvJbWLGZtaoG0mrIeW";
  alexrpi4tp = [ alexrpi4tp-user alexrpi4tp-system ];
  alexrpi4dorm-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/FOfzUF0nSno+780hSUGX1bDPqmfZpEUG0f/imEl3r";
  alexrpi4dorm-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkF/r+q6RNOVfjbNuThgEzgbPW2WKvTMBofSUG4FFDS";
  alexrpi4dorm = [ alexrpi4dorm-user alexrpi4dorm-system ];
  # asus-nixos-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf9DW0O5gkq0ephXxUl7SXgb6TMkAA7RgB9NIl4oKNi";
  # asus-nixos-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDotz0cHltq3gt5Iln5IKhPnj9PQbLp2iwi8KsnFc7Om";
  # asus-nixos = [ asus-nixos-user asus-nixos-system ];
  m1-nixos-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICid1/VEdjJct9RWaL4Hz+igBnu185ySy8kuAxVHZGyN";
  m1-nixos-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJPWsTz/bUpLRSRkwiInX7h6haF7hj/kmZUu11EzNp3i";
  m1-nixos = [ m1-nixos-user m1-nixos-system ];
in
{
  "ddtoken-acer-tp.age".publicKeys = acer-tp;
  "ddtoken-alexrpi4tp.age".publicKeys = alexrpi4tp;
  "wg-acer-tp.age".publicKeys = acer-tp;
  "wg-m1-nixos.age".publicKeys = m1-nixos;
  "nix-m1-nixos.age".publicKeys = m1-nixos;
  "nix-alexrpi4tp.age".publicKeys = alexrpi4tp;
  "nix-alexrpi4dorm.age".publicKeys = alexrpi4dorm;
  "nix-acer-tp.age".publicKeys = acer-tp;
  "nix-acer-nixos.age".publicKeys = acer-nixos;
  # "wg-asus-nixos.age".publicKeys = asus-nixos;
}
