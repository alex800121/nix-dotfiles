{ config, lib, ... }:
let
  inherit (config.networking) hostName;
  # setCred = "ssh_host_borgbackup_vaultwarden:" + lib.strings.concatStrings
  #   (lib.strings.splitString
  #     "\n"
  #     (builtins.readFile ../../secrets/ssh_host_borgbackup_vaultwarden-${hostName}));
  jobName = "vaultwarden";
in
{
  # systemd.services."borgbackup-job-${jobName}".serviceConfig.SetCredentialEncrypted = setCred;
  users.extraUsers."borg" = {
    isSystemUser = true;
    group = "borg";
  };
  users.extraGroups."borg" = { };
  age.secrets.passphrase_borgbackup_vaultwarden = {
    file = ../../secrets/passphrase_borgbackup_vaultwarden_${hostName}.age;
    owner = "borg";
    group = "borg";
    mode = "600";
  };
  age.secrets.ssh_host_borgbackup_vaultwarden = {
    file = ../../secrets/ssh_host_borgbackup_vaultwarden_${hostName}.age;
    owner = "borg";
    group = "borg";
    mode = "600";
  };
  services.borgbackup.jobs."${jobName}" = {
    user = "root";
    group = "root";
    repo = "borg@acer-tp:.";
    paths = [ "/var/lib/vaultwarden" ];
    doInit = true;
    encryption = {
      mode = "repokey";
      passCommand = "cat ${config.age.secrets.passphrase_borgbackup_vaultwarden.path}";
    };
    environment = {
      BORG_RSH = "ssh -i ${config.age.secrets.ssh_host_borgbackup_vaultwarden.path}";
    };
    startAt = "daily";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = -1; # Keep at least one archive for each month
    };
  };
}
