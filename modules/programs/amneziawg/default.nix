{ inputs, self, ... }: {
  flake.nixosModules.amneziawg-client =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      nixpkgsUnstable = import inputs.nixpkgsUnstable {
        inherit (config.nixpkgs.hostPlatform) system;
      };
    in
    {
      imports = [ inputs.agenix.nixosModules.default ];
      options = { };
      config = {
        nixpkgs.overlays = [
          (self: super: { amneziawg-tools = nixpkgsUnstable.amneziawg-tools; })
          (self: super: { amneziawg-go = nixpkgsUnstable.amneziawg-go; })
        ];

        boot.kernelPackages = nixpkgsUnstable.linuxPackages_6_18;

        networking.networkmanager = {
          unmanaged = [ "interface-name:awg0" ];
        };

        services.resolved.enable = true;
        networking.firewall.checkReversePath = "loose";

        age.secrets."awg0.conf".file = ../../../secrets/amneziawg-private-${config.networking.hostName}.age;

        systemd.services.wg-quick-awg0.serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };

        # AmneziaWG server
        networking.wg-quick.interfaces.awg0 = {
          type = "amneziawg";
          configFile = config.age.secrets."awg0.conf".path;
          autostart = false;
        };

      };
    };
  flake.nixosModules.amneziawg-server =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      nixpkgsUnstable = import inputs.nixpkgsUnstable {
        inherit (config.nixpkgs.hostPlatform) system;
      };
      port = 51820 + config.initConfig.topo.${config.networking.hostName}.id;
    in
    {
      imports = [
        inputs.agenix.nixosModules.default
        self.nixosModules.topo
      ];
      options = { };
      config = {
        age.secrets."cloudflare.env".file = ../../../secrets/cloudflare.age;

        services.cloudflare-ddns = {
          enable = true;
          ip4Domains = [
            "${config.networking.hostName}ipv4.alexgate.dpdns.org"
            "${config.networking.hostName}.alexgate.dpdns.org"
          ];
          ip6Domains = [
            "${config.networking.hostName}ipv6.alexgate.dpdns.org"
            "${config.networking.hostName}.alexgate.dpdns.org"
          ];
          credentialsFile = config.age.secrets."cloudflare.env".path;
          updateCron = "@every 5m";
        };

        nixpkgs.overlays = [
          (self: super: { amneziawg-tools = nixpkgsUnstable.amneziawg-tools; })
          (self: super: { amneziawg-go = nixpkgsUnstable.amneziawg-go; })
        ];

        boot.kernelPackages = nixpkgsUnstable.linuxPackages_6_18;

        age.secrets."awg0.conf".file = ../../../secrets/amneziawg-private-${config.networking.hostName}.age;

        # AmneziaWG server
        networking.wg-quick.interfaces.awg0 = {
          type = "amneziawg";
          configFile = config.age.secrets."awg0.conf".path;
          autostart = true;
        };

        # Firewall
        networking.firewall = {
          enable = true;
          allowedUDPPorts = [ port ];
          trustedInterfaces = [ "awg0" ];
        };

        # IPv4 forwarding + NAT
        networking.nat = {
          enable = true;
          enableIPv6 = true;
          externalInterface = "eth0";
          internalInterfaces = [ "awg0" ];
        };

      };
    };
}
