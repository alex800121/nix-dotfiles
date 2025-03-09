{ inputs, ... }: {

  imports = [
    ./rpi4.nix
    ./distributed-builds.nix
    ../hardware/alexrpi4tp.nix
    ../programs/sshd
    ../programs/tailscale/server.nix
    ../programs/nix-ld
    ../programs/code-tunnel
    # ../programs/duckdns
    ../programs/vaultwarden
    (import ../programs/borgbackup/vaultwarden.nix "acer-tp")
    (import ../programs/borgbackup/vaultwarden.nix "oracle")
    # ../programs/borgbackup/vaultwarden.nix
    inputs.agenix.nixosModules.default
  ];
}
