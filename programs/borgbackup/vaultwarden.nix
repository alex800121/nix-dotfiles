{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.networking) hostName;
  cfg = config.services.vaultwarden.borgbackup;
  timeOffset =
    (
      x:
      let
        i = builtins.stringLength x - 2;
      in
      builtins.substring i 2 x
    )
      "00${builtins.toString config.initConfig.id}";
  passphrase = "passphrase_borgbackup_vaultwarden";
  dbUserName = config.services.mysql.user;
  dbGroupName = config.services.mysql.group;
  userName = "vaultwarden";
  groupName = "vaultwarden";
  mergeSecrets =
    serverName:
    let
      sshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_${hostName}";
      dbSshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_db_${hostName}";
    in
    {
      secrets."${dbSshHostKey}" = {
        file = ../../secrets/${dbSshHostKey}.age;
        owner = dbUserName;
        group = dbGroupName;
        mode = "600";
      };
      secrets."${sshHostKey}" = {
        file = ../../secrets/${sshHostKey}.age;
        owner = userName;
        group = groupName;
        mode = "600";
      };
    };
  mergeServices =
    serverName:
    let
      sshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_${hostName}";
      dbSshHostKey = "ssh_host_borgbackup_${serverName}_vaultwarden_db_${hostName}";
    in
    {
      jobs."vaultwarden-db-${serverName}" = {
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
        startAt = "*-*-* ${timeOffset}:00:00";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
      };
      jobs."vaultwarden-${serverName}" = {
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
        startAt = "*-*-* ${timeOffset}:01:00";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
      };
    };
in
{
  options = {
    services.vaultwarden.borgbackup.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    services.vaultwarden.borgbackup.servers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config.users = lib.mkIf cfg.enable {
    extraUsers."${dbUserName}" = {
      createHome = true;
      home = "/var/lib/system_home/${dbUserName}";
      extraGroups = [ groupName ];
    };
    extraUsers."${userName}" = {
      createHome = true;
      home = "/var/lib/system_home/${userName}";
    };
  };
  config.age = lib.mkIf cfg.enable (
    lib.mkMerge (
      map mergeSecrets cfg.servers
      ++ [
        {
          secrets."${passphrase}" = {
            file = ../../secrets/${passphrase}.age;
            owner = userName;
            group = groupName;
            mode = "660";
          };
        }
      ]
    )
  );
  config.services.borgbackup = lib.mkIf cfg.enable (lib.mkMerge (map mergeServices cfg.servers));
}
