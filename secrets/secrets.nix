let
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8QIkayntlJgarKb0rt5fy+413SfARjxszlE8tut4HB";
  acer-tp = [ acer-tp-user acer-tp-system ];
  alexrpi4tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM";
  alexrpi4tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYWWE+KePNOcBGSoBABUP8dZcUvJbWLGZtaoG0mrIeW";
  alexrpi4tp = [ alexrpi4tp-user alexrpi4tp-system ];
  asus-nixos-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf9DW0O5gkq0ephXxUl7SXgb6TMkAA7RgB9NIl4oKNi";
  asus-nixos-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDotz0cHltq3gt5Iln5IKhPnj9PQbLp2iwi8KsnFc7Om";
  asus-nixos = [ asus-nixos-user asus-nixos-system ];
  m1-nixos-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICid1/VEdjJct9RWaL4Hz+igBnu185ySy8kuAxVHZGyN";
  m1-nixos-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFte0h3WjujSOGEUOiD/ruFXMatUobyFJmmpD0iXD8Jy";
  m1-nixos = [ m1-nixos-user m1-nixos-system ];
in
{
  "ddtoken-acer-tp.age".publicKeys = acer-tp;
  "ddtoken-alexrpi4tp.age".publicKeys = alexrpi4tp;
  "wg-acer-tp.age".publicKeys = acer-tp;
  "wg-m1-nixos.age".publicKeys = m1-nixos;
  # "wg-asus-nixos.age".publicKeys = asus-nixos;
}
