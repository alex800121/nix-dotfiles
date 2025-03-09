{ config, ... }:
let inherit (config.networking) hostName; in {
  services.borgbackup.repos."vaultwarden".path = "/var/lib/borgbackup/vaultwarden";
  # services.borgbackup.repos."vaultwarden".user = "root";
  # services.borgbackup.repos."vaultwarden".group = "root";
  services.borgbackup.repos."vaultwarden".quota = "50G";
  services.borgbackup.repos."vaultwarden".authorizedKeys = [
    (builtins.readFile ../../secrets/ssh_host_borgbackup_vaultwarden_${hostName}.pub)
  ];
  services.borgbackup.repos."vaultwarden".allowSubRepos = false;
  # services.borgbackup.repos."vaultwarden".allowSubRepos = true;
}
