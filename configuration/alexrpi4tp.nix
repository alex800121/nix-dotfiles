{ inputs, ... }:
{
  imports = [
    ./rpi4.nix
    ./distributed-builds.nix
    ./ssh-serve.nix
    ../hardware/alexrpi4tp.nix
    ../programs/tailscale/server.nix
    ../programs/nix-ld
    # ../programs/code-tunnel
    ../programs/vaultwarden
    ../programs/borgbackup/vaultwarden.nix
    inputs.agenix.nixosModules.default
  ];
  services.vaultwarden.borgbackup.enable = true;
  services.vaultwarden.borgbackup.servers = [ "acer-tp" ];
}
