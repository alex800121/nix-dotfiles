let
  acer-tp-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjG4XVmjDi/U0YRWGWdUic1biaLwt2hEUUnsNvVKxiG";
  acer-tp-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8QIkayntlJgarKb0rt5fy+413SfARjxszlE8tut4HB";
  acer-tp = [ acer-tp-user acer-tp-system ];
in
{
  "ddtoken.age".publicKeys = acer-tp;
}
