{ pkgs, inputs, ... }:
{
  imports = [
    ./rpi4.nix
    ./topo.nix
    ./distributed-builds.nix
    ./ssh-serve.nix
    ../hardware/alexrpi4tp.nix
    ../programs/tailscale/server.nix
    ../programs/nix-ld
    # ../programs/code-tunnel
    ../programs/vaultwarden
    ../programs/borgbackup/vaultwarden.nix
    inputs.agenix.nixosModules.default
    ../programs/nvim/minimal.nix
  ];
  services.vaultwarden.borgbackup.enable = true;
  services.vaultwarden.borgbackup.servers = [ "acer-tp" ];

  fileSystems."/".options = [
    "noatime"
    "compress=zstd"
  ];
  fileSystems."/home".options = [
    "noatime"
    "compress=zstd"
  ];
  fileSystems."/nix".options = [
    "noatime"
    "compress=zstd"
  ];
  fileSystems."/swap".options = [ "noatime" ];
  fileSystems."/boot".neededForBoot = true;
  swapDevices = [ { device = "/swap/swapfile"; } ];

  documentation.man.enable = true;
  documentation.man.cache.enable = true;
  documentation.man.cache.generateAtRuntime = true;
}
