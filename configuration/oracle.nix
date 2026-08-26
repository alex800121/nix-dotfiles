{ inputs, ... }:
{
  imports = [
    ./oracleCommon.nix
    ./topo.nix
    # ./ssh-serve.nix
    inputs.self.nixosModules.ssh-serve
    ../programs/vaultwarden
    ../programs/borgbackup/vaultwarden.nix
  ];

  services.vaultwarden.borgbackup.enable = true;
  services.vaultwarden.borgbackup.servers = [ "acer-tp" ];
  initConfig.hostName = "oracle";
}
