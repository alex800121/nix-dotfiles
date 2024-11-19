{ lib, userConfig, config, pkgs, ... }:
let
  inherit (userConfig) hostName;
  # geoclue-url = ./geoclue-url;
  # google-api-key =
  #   lib.strings.concatStrings
  #     (lib.strings.splitString
  #       "\n"
  #       (builtins.readFile ../secrets/google-api-key-${userConfig.hostName})
  #     );
in
{
  services.automatic-timezoned.enable = true;

  time.timeZone = lib.mkForce null;

  location.provider = "geoclue2";

  # age.secrets."google-geoloc-${hostName}" = {
  #   file = ../secrets/google-geoloc-${hostName}.age;
  #   owner = "geoclue";
  #   group = "geoclue";
  #   mode = "0600";
  # };
  services.avahi.enable = true;

  services.geoclue2.enable = lib.mkForce true;
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  services.geoclue2.submissionUrl = "https://beacondb.net/v2/geosubmit";
  services.geoclue2.submitData = true;
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

  # systemd.services.geoclue.serviceConfig.SetCredentialEncrypted =
  #   "google.api.key:" + google-api-key;
  # systemd.services.geoclue.serviceConfig.ConfigurationDirectory = "geoclue/conf.d";
  # systemd.services.geoclue.serviceConfig.RuntimeDirectory = "geoclue";
  # systemd.services.geoclue.preStart = ''
  #   cp ${geoclue-url} $RUNTIME_DIRECTORY/50-url.conf
  #   chmod 600 $RUNTIME_DIRECTORY/50-url.conf
  #   ${pkgs.replace-secret}/bin/replace-secret @GOOGLE_API_KEY@ $CREDENTIALS_DIRECTORY/google.api.key $RUNTIME_DIRECTORY/50-url.conf
  #   ln -s --backup=simple $RUNTIME_DIRECTORY/50-url.conf $CONFIGURATION_DIRECTORY/
  # '';
  # systemd.services.geoclue.postStop = ''
  #   unlink $CONFIGURATION_DIRECTORY/50-url.conf
  # '';

  # environment.etc."geoclue/conf.d/90-provider.conf" = {
  #   enable = true;
  #   source = config.age.secrets."google-geoloc-${hostName}".path;
  #   user = "geoclue";
  #   group = "geoclue";
  #   mode = "0600";
  # };
}
