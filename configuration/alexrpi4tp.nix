{ pkgs, inputs, lib, ... }:
{
  imports = [
    ./rpi4.nix
    ./topo.nix
    # ./distributed-builds.nix
    # ./ssh-serve.nix
    inputs.self.nixosModules.distributed-builds
    inputs.self.nixosModules.ssh-serve
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.supportedFilesystems.btrfs = true;

  boot.supportedFilesystems.btrfs = true;

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

  networking.networkmanager.enable = false;
}
