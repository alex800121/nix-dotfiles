let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjG4XVmjDi/U0YRWGWdUic1biaLwt2hEUUnsNvVKxiG";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8QIkayntlJgarKb0rt5fy+413SfARjxszlE8tut4HB";
in
{
  "ddtoken.age".publicKeys = [ user system ];
}
