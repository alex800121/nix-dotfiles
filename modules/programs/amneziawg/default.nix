{ inputs, ... }: {
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

        age.secrets."amneziawg-private-${config.networking.hostName}.key".file =
          ../../../secrets/amneziawg-private-${config.networking.hostName}.age;

        systemd.services.wg-quick-awg0.serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };

        # AmneziaWG server
        networking.wg-quick.interfaces.awg0 = {
          type = "amneziawg";
          configFile = config.age.secrets."amneziawg-private-${config.networking.hostName}.key".path;
          autostart = true;
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

        age.secrets."amneziawg-private-${config.networking.hostName}.key".file =
          ../../../secrets/amneziawg-private-${config.networking.hostName}.age;

        # AmneziaWG server
        networking.wg-quick.interfaces.awg0 = {
          type = "amneziawg";
          configFile = config.age.secrets."amneziawg-private-${config.networking.hostName}.key".path;
          autostart = true;
        };

        # Firewall
        networking.firewall = {
          enable = true;
          allowedUDPPorts = [ 51820 ];
          trustedInterfaces = [ "awg0" ];
        };

        # IPv4 forwarding + NAT
        networking.nat = {
          enable = true;
          externalInterface = "eth0";
          internalInterfaces = [ "awg0" ];
        };

      };
    };
}
