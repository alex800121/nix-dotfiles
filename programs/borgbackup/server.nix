{ lib, userConfig, config, ... }:
let
  inherit (config.networking) hostName;
  setRepo = { repoName, subRepo, clients }:
    {
      services.borgbackup.repos."${repoName}" = {
        path = "/var/lib/borgbackup/${repoName}";
        quota = "50G";
        authorizedKeys =
          lib.map
            (clientName:
              (builtins.readFile ../../secrets/ssh_host_borgbackup_${hostName}_vaultwarden_${clientName}.pub)
            )
            clients;
        allowSubRepos = false;
      };
    };
in
lib.attrsets.mergeAttrsList (lib.map setRepo userConfig.borgbackupRepo)
