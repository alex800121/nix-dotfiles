{ pkgs, userConfig, config, ... }:
let
  inherit (config.networking) hostName;
in
{
  imports = [ ../borgbackup/vaultwarden.nix ];
  users.extraUsers."vaultwarden" = {
    isSystemUser = true;
    group = "vaultwarden";
  };
  users.extraGroups."vaultwarden" = { };
  age.secrets."vaultwarden.env" = {
    file = ../../secrets/env_vaultwarden_${hostName}.age;
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "600";
  };
  environment.systemPackages = with pkgs; [
    vaultwarden
  ];
  services.tailscale.permitCertUid = config.services.caddy.user;
  services.caddy.enable = true;
  services.caddy.virtualHosts."${hostName}.taildaa926.ts.net:8001" = {
    extraConfig = ''
      tls {
        get_certificate tailscale
      }
      # redir /vaultwarden /vaultwarden/
      # handle_path /vaultwarden/* {
      #   reverse_proxy /* http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
      # }
      reverse_proxy http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };
  services.vaultwarden.enable = true;
  services.vaultwarden.environmentFile = config.age.secrets."vaultwarden.env".path;
  services.vaultwarden.backupDir = "/var/backup/vaultwarden";
  services.vaultwarden.config = {
    # DISABLE_ADMIN_TOKEN = false;
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = "8000";
  };
}
