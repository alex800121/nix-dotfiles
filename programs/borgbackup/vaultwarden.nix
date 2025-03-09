serverName: { config, lib, ... }:
let
  inherit (config.networking) hostName;
  # setCred = "ssh_host_borgbackup_vaultwarden:" + lib.strings.concatStrings
  #   (lib.strings.splitString
  #     "\n"
  #     (builtins.readFile ../../secrets/ssh_host_borgbackup_vaultwarden-${hostName}));
  jobName = "vaultwarden";
  passphrase = "passphrase_borgbackup_vaultwarden_${hostName}";
  sshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_${hostName}";
in
{
  # systemd.services."borgbackup-job-${jobName}".serviceConfig.SetCredentialEncrypted = setCred;
  age.secrets.${passphrase} = {
    file = ../../secrets/${passphrase}.age;
    owner = "root";
    group = "root";
    mode = "600";
  };
  age.secrets."${sshHostKey}" = {
    file = ../../secrets/${sshHostKey}.age;
    owner = "root";
    group = "root";
    mode = "600";
  };
  services.borgbackup.jobs."${jobName}-${serverName}" = {
    user = "root";
    group = "root";
    repo = "borg@${serverName}:.";
    paths = [ "/var/lib/vaultwarden" ];
    doInit = true;
    encryption = {
      mode = "repokey";
      passCommand = "cat ${config.age.secrets.${passphrase}.path}";
    };
    environment = {
      BORG_RSH = "ssh -i ${config.age.secrets.${sshHostKey}.path}";
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
