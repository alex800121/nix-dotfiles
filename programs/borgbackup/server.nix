{ ... }: {
  services.borgbackup.repos."vaultwarden".path = "/var/lib/borgbackup/vaultwarden";
  # services.borgbackup.repos."vaultwarden".user = "root";
  # services.borgbackup.repos."vaultwarden".group = "root";
  services.borgbackup.repos."vaultwarden".quota = "50G";
  services.borgbackup.repos."vaultwarden".authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnZxTdSHinReC8qDH40sF6vTEmvNQei/OPfsxDtabLB root@alexrpi4tp"
  ];
  services.borgbackup.repos."vaultwarden".allowSubRepos = false;
  # services.borgbackup.repos."vaultwarden".allowSubRepos = true;
}
