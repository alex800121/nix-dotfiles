{ inputs, ... }: {

  imports = [
    ./rpi4.nix
    ./distributed-builds.nix
    ./ssh-serve.nix
    ../hardware/alexrpi4tp.nix
    ../programs/sshd
    ../programs/tailscale/server.nix
    ../programs/nix-ld
    ../programs/code-tunnel
    # ../programs/duckdns
    ../programs/vaultwarden
    (import ../programs/borgbackup/vaultwarden.nix [ "acer-tp" ])
    inputs.agenix.nixosModules.default
  ];
}
