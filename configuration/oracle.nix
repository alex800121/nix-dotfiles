{ ... }:
{
  imports = [
    ./oracleCommon.nix
    ./ssh-serve.nix
    ../programs/vaultwarden
    ../programs/borgbackup/vaultwarden.nix
  ];

  services.vaultwarden.borgbackup.enable = true;
  services.vaultwarden.borgbackup.servers = [ "acer-tp" ];
  initConfig.hostName = "oracle";
}
