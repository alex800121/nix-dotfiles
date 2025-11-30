{ lib, ... }:
{
  time.timeZone = null;

  location.provider = "geoclue2";

  services.geoclue2.enable = true;
  services.geoclue2.submitData = true;
  services.geoclue2.appConfig."google-chrome" = {
    isSystem = false;
    isAllowed = true;
    desktopID = "google-chrome";
  };
  services.geoclue2.appConfig."com.google.Chrome" = {
    isSystem = false;
    isAllowed = true;
    desktopID = "com.google.Chrome";
  };
}
