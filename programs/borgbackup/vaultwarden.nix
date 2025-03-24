serverName: { config, lib, ... }:
let
  inherit (config.networking) hostName;
  passphrase = "passphrase_borgbackup_vaultwarden_${hostName}";
  sshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_${hostName}";
  userName = config.users.users.vaultwarden.name;
  groupName = config.users.groups.vaultwarden.name;
in
{
  users.users.vaultwarden.createHome = true;
  users.users.vaultwarden.home = "/home/vaultwarden";
  age.secrets.${passphrase} = {
    file = ../../secrets/${passphrase}.age;
    owner = userName;
    group = groupName;
    mode = "600";
  };
  age.secrets."${sshHostKey}" = {
    file = ../../secrets/${sshHostKey}.age;
    owner = userName;
    group = groupName;
    mode = "600";
  };
  services.borgbackup.jobs."vaultwarden-${serverName}" = {
    user = userName;
    group = groupName;
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
