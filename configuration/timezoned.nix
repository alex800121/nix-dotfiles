{ lib, userConfig, config, ... }: let
  inherit (userConfig) hostName;
in {
  services.automatic-timezoned.enable = true;

  time.timeZone = lib.mkForce null;

  location.provider = "geoclue2";

  age.secrets."google-geoloc-${hostName}" = {
    file = ../secrets/google-geoloc-${hostName}.age;
    owner = "geoclue";
    group = "geoclue";
    mode = "0600";
  };

  services.geoclue2.enable = lib.mkDefault true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  services.geoclue2.submissionUrl = "https://beacondb.net/v2/geosubmit";
  services.geoclue2.submitData = true;
  environment.etc."geoclue/conf.d/90-provider.conf" = {
    enable = true;
    source = config.age.secrets."google-geoloc-${hostName}".path;
    user = "geoclue";
    group = "geoclue";
    mode = "0600";
  };
}
