{ lib, pkgs, userConfig, ... }:
let
  setCred = "ddtoken:" + lib.strings.concatStrings
    (lib.strings.splitString
      "\n"
      (builtins.readFile ../../secrets/ddtoken-${userConfig.hostName}));
in
{
  boot.initrd.systemd.extraBin = {
    curl = "${pkgs.curl}/bin/curl";
    systemd-creds = "${pkgs.systemd}/bin/systemd-creds";
  };


  boot.initrd.systemd.services.duckdns = {
    enable = true;
    description = "duckdns update";
    wantedBy = [ "initrd.target" ];
    after = [
      # "nss-lookup.target"
      # "nss-user-lookup.target"
      "systemd-resolved.service"
      "systemd-networkd-wait-online.service"
      "network-online.target"
      "initrd-nixos-copy-secrets.service"
    ];
    wants = [
      # "nss-lookup.target"
      # "nss-user-lookup.target"
      "systemd-resolved.service"
      "systemd-networkd-wait-online.service"
      "network-online.target"
      "initrd-nixos-copy-secrets.service"
    ];
    before = [ "shutdown.target" ];
    conflicts = [ "shutdown.target" ];
    path = [ pkgs.bash ];
    script = ''
      /bin/curl -k "https://www.duckdns.org/update?domains=${userConfig.url}&token=$(/bin/systemd-creds cat ddtoken)&ip=" 
    '';
    serviceConfig = {
      Type = "oneshot";
      # DynamicUser = true;
      # RuntimeDirectoryMode = "0700";
      # RuntimeDirectory = "duckdns";
      SetCredentialEncrypted = setCred;
      Restart = "on-failure";
      RestartSec = "5s";
    };
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

}
