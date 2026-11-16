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

        age.secrets."awg0.conf".file = ../../../secrets/awg/conf-${config.networking.hostName}.age;

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
      inherit (config.networking) hostName;
      inherit (config.initConfig.topo.${hostName}) peers id;
      inherit (builtins) toString;
      ip4 = "10.88.0.${toString id}/32";
      ip6 = "fd88:88::${toString id}/128";
      peerConf = builtins.map (
        p:
        let
          pid = (config.initConfig.topo.${p}).id;
          pip4 = "10.88.0.${toString pid}/32";
          pip6 = "fd88:88::${toString pid}/128";
        in
        {
          name = p;
          publicKey = builtins.readFile ../../../secrets/awg/${p}.pub;
          allowedIPs = [
            pip4
            pip6
          ];
          endpoint = "${p}ipv6.alexgate.dpdns.org:51820";
          persistentKeepalive = 25;
          dynamicEndpointRefreshRestartSeconds = 10;
        }
      ) peers;
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
            "${hostName}ipv4.alexgate.dpdns.org"
            "${hostName}.alexgate.dpdns.org"
          ];
          ip6Domains = [
            "${hostName}ipv6.alexgate.dpdns.org"
            "${hostName}.alexgate.dpdns.org"
          ];
          credentialsFile = config.age.secrets."cloudflare.env".path;
          updateCron = "@every 5m";
        };

        nixpkgs.overlays = [
          (self: super: { amneziawg-tools = nixpkgsUnstable.amneziawg-tools; })
          (self: super: { amneziawg-go = nixpkgsUnstable.amneziawg-go; })
        ];

        boot.kernelPackages = nixpkgsUnstable.linuxPackages_6_18;

        age.secrets."awg.key".file = ../../../secrets/awg/${hostName}.age;
        age.secrets."header.key".file = ../../../secrets/awg/header.age;

        # AmneziaWG server
        networking.wireguard.useNetworkd = false;
        networking.wireguard.interfaces.awg0 = {
          ips = [
            ip4
            ip6
          ];
          type = "amneziawg";
          listenPort = 51820;
          privateKeyFile = config.age.secrets."awg.key".path;
          dynamicEndpointRefreshSeconds = 30;
          peers = peerConf;
          mtu = 1280;
          extraOptions = {
            Jc = 4;
            Jmin = 40;
            Jmax = 100;
            S1 = 64;
            S2 = 96;
            S3 = 16;
            S4 = 16;
            H1 = 918517201;
            H2 = 918517202;
            H3 = 918517203;
            H4 = 918517204;

            "content-padding-addition" = 16;
            "rekey-after-time" = "100-120";
            "rekey-timeout" = "5-7";
            "keepalive-timeout" = "10-15";
          };
          postSetup = ''
            ${pkgs.amneziawg-tools}/bin/awg set awg0 \
            header-protection-key ${config.age.secrets."header.key".path}
          '';
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
          enableIPv6 = true;
          externalInterface = "eth0";
          internalInterfaces = [ "awg0" ];
        };

      };
    };
}
