servers: { config, lib, pkgs, ... }:
let
  inherit (config.networking) hostName;
  passphrase = "passphrase_borgbackup_vaultwarden";
  dbUserName = config.services.mysql.user;
  dbGroupName = config.services.mysql.group;
  userName = "vaultwarden";
  groupName = "vaultwarden";
  mergeServers = serverName:
    let
      sshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_${hostName}";
      dbSshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_db_${hostName}";
    in
    {
      age.secrets."${dbSshHostKey}" = {
        file = ../../secrets/${dbSshHostKey}.age;
        owner = dbUserName;
        group = dbGroupName;
        mode = "600";
      };
      age.secrets."${sshHostKey}" = {
        file = ../../secrets/${sshHostKey}.age;
        owner = userName;
        group = groupName;
        mode = "600";
      };
      services.borgbackup.jobs."vaultwarden-db-${serverName}" = {
        user = dbUserName;
        group = dbGroupName;
        repo = "borg@${serverName}:.";
        doInit = true;
        dumpCommand = pkgs.writeScript "dbbackup.sh" ''
          ${pkgs.mariadb}/bin/mariadb-backup --user=mysql --backup --stream=xbstream
        '';
        encryption = {
          mode = "repokey";
          passCommand = "cat ${config.age.secrets.${passphrase}.path}";
        };
        environment = {
          BORG_RSH = "ssh -i ${config.age.secrets.${dbSshHostKey}.path}";
        };
        startAt = "daily";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
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
    };
in
lib.foldl'
  (acc: serverName: lib.recursiveUpdate acc (mergeServers serverName))
{
  users.extraUsers."${dbUserName}" = {
    createHome = true;
    home = "/home/${dbUserName}";
    extraGroups = [ groupName ];
  };
  users.extraUsers."${userName}" = {
    createHome = true;
    home = "/home/${userName}";
  };
  age.secrets."${passphrase}" = {
    file = ../../secrets/${passphrase}.age;
    owner = userName;
    group = groupName;
    mode = "660";
  };
}
  servers
