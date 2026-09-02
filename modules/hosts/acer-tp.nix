{ inputs, self, ... }: {
  flake.nixosConfigurations.acer-tp = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.acer-tp ];
  };
  flake.nixosModules.acer-tp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg0 = {
        matchConfig = {
          Name = "eth0";
        };
        networkConfig = {
          DHCP = true;
          MulticastDNS = true;
          LLMNR = true;
        };
        linkConfig = {
          # RequiredForOnline = true;
          RequiredFamilyForOnline = "any";
          Multicast = true;
          AllMulticast = true;
        };
      };
    in
    {
      imports = [
        self.nixosModules.default
        self.nixosModules.topo
        self.nixosModules.secure-boot
        self.nixosModules.distributed-builds
        self.nixosModules.ssh-serve
        self.nixosModules.timezoned
        self.nixosModules.initrd-network
        _hardware/acer-tp.nix
        _hardware/desktop.nix
        # self.nixosModules.nix-ld
        self.nixosModules.tailscale-server
        inputs.agenix.nixosModules.default
        self.nixosModules.vaultwarden
      ];

      initConfig.defaultUser = "alex800121";
      initConfig.hostName = "acer-tp";

      services.borgbackup.repos."vaultwarden" = {
        authorizedKeys = builtins.map builtins.readFile [
          ../../secrets/ssh_host_borgbackup_acer-tp_vaultwarden_alexrpi4tp.pub
          ../../secrets/ssh_host_borgbackup_acer-tp_vaultwarden_db_alexrpi4tp.pub
          ../../secrets/ssh_host_borgbackup_acer-tp_vaultwarden_oracle.pub
          ../../secrets/ssh_host_borgbackup_acer-tp_vaultwarden_db_oracle.pub
        ];
        quota = "50G";
        allowSubRepos = false;
      };

      networking.networkmanager.enable = false;
      networking.useNetworkd = true;
      systemd.network.enable = true;

      systemd.network.wait-online.anyInterface = true;
      boot.initrd.systemd.network.wait-online.anyInterface = true;
      systemd.network.wait-online.ignoredInterfaces = [ "wlp0s20f3" ];

      boot.kernelParams = [ "net.ifnames=0" ];
      systemd.network.networks."10-eth0" = cfg0;
      boot.initrd.systemd.network.networks."10-eth0" = cfg0;

      boot.initrd.luks.devices."enc".preLVM = true;
      boot.initrd.luks.devices."enc".allowDiscards = true;
      boot.initrd.luks.devices."enc".bypassWorkqueues = true;
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
      fileSystems."/data".options = [
        "noatime"
        "compress=zstd"
      ];
      fileSystems."/swap".options = [ "noatime" ];
      swapDevices = [ { device = "/swap/swapfile"; } ];
    };
}
