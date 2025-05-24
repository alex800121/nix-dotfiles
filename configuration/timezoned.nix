{ lib, ... }:
{
  time.timeZone = null;

  location.provider = "geoclue2";

  services.geoclue2.enable = true;
  services.geoclue2.submitData = true;
}
