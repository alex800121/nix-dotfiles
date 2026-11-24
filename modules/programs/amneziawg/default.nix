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
      inherit (config.networking) hostName;
      inherit (config.initConfig.topo.${hostName}) id;
      peers = config.initConfig.topo.${hostName}.awgPeers;
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
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "${p}.alexgate.dpdns.org:51820";
          persistentKeepalive = 25;
          dynamicEndpointRefreshRestartSeconds = 10;
        }
      ) peers;
      ip = "${pkgs.iproute2}/bin/ip";
      table = "2468";
      mark = "0xca6c";
    in
    {
      imports = [
        inputs.agenix.nixosModules.default
        self.nixosModules.topo
      ];
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

        # services.dnsproxy = {
        #   enable = true;
        #
        #   settings = {
        #     listen-addrs = [ "127.0.0.1" ];
        #     listen-ports = [ 5053 ];
        #
        #     upstream = [
        #       "https://1.1.1.1/dns-query"
        #     ];
        #   };
        # };
        #
        # systemd.services.doh-bypass = {
        #   description = "Direct DoH bootstrap routing";
        #
        #   wantedBy = [ "multi-user.target" ];
        #   before = [ "dnsproxy.service" ];
        #
        #   path = [ pkgs.iproute2 ];
        #
        #   serviceConfig = {
        #     Type = "oneshot";
        #     RemainAfterExit = true;
        #   };
        #
        #   script = ''
        #     # Reconcile existing rules, including manually added ones
        #     ip -4 rule del pref 5200 2>/dev/null || true
        #     ip -4 rule del pref 5201 2>/dev/null || true
        #
        #     ip -4 rule add pref 5200 \
        #       to 1.1.1.1/32 \
        #       ipproto tcp dport 443 \
        #       lookup main
        #
        #     ip -4 rule add pref 5201 \
        #       to 1.0.0.1/32 \
        #       ipproto tcp dport 443 \
        #       lookup main
        #   '';
        #
        #   preStop = ''
        #     ip -4 rule del pref 5200 2>/dev/null || true
        #     ip -4 rule del pref 5201 2>/dev/null || true
        #   '';
        # };
        #
        # systemd.services.dnsproxy = {
        #   requires = [ "doh-bypass.service" ];
        #   after = [ "doh-bypass.service" ];
        # };
        #
        # services.resolved = {
        #   settings.Resolve = {
        #     DNS = [ "127.0.0.1:5053" ];
        #
        #     # Oracle DDNS 優先使用本機 DoH Proxy
        #     Domains = [ "~." ];
        #   };
        # };
        #
        # systemd.services."wireguard-awg0-peer-oracle-refresh" = {
        #   wants = [ "dnsproxy.service" ];
        #   after = [ "dnsproxy.service" ];
        # };
        #
        services.resolved.enable = true;
        networking.firewall.checkReversePath = "loose";

        # AmneziaWG server
        age.secrets."awg.key".file = ../../../secrets/awg/${hostName}.age;
        age.secrets."header.key".file = ../../../secrets/awg/header.age;

        # AmneziaWG server
        networking.wireguard.useNetworkd = false;
        networking.wireguard.interfaces.awg0 = {
          # 將 AllowedIPs 的路由放到專用 table
          table = table;
          allowedIPsAsRoutes = true;

          # 標記 AWG 外層 UDP，避免 routing loop
          fwMark = mark;

          postSetup = ''
            ${pkgs.amneziawg-tools}/bin/awg set awg0 \
            header-protection-key ${config.age.secrets."header.key".path}
            for family in -4 -6; do
              # 保留本地 LAN / 其他更明確的路由，
              # 但忽略 main table 的 default route
              ${ip} "$family" rule add \
                pref 5300 \
                lookup main suppress_prefixlength 0

              # 普通流量走 AWG table
              # 帶有 AWG fwmark 的外層 UDP 不會匹配
              ${ip} "$family" rule add \
                pref 5301 \
                not fwmark ${mark} lookup ${table}
            done
          '';

          preShutdown = ''
            for family in -4 -6; do
              ${ip} "$family" rule del \
                pref 5301 \
                not fwmark ${mark} lookup ${table} \
                2>/dev/null || true

              ${ip} "$family" rule del \
                pref 5300 \
                lookup main suppress_prefixlength 0 \
                2>/dev/null || true
            done
          '';
          ips = [
            ip4
            ip6
          ];
          type = "amneziawg";
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
        };

        age.secrets."cloudflare.include" = {
          file = ../../../secrets/cloudflare-inadyn.age;
          owner = "inadyn";
          group = "inadyn";
        };

        services.inadyn = {
          enable = true;
          settings.allow-ipv6 = true;
          interval = "*:0/10";
          settings.provider = {
            "cloudflare.com:2" = {
              include = config.age.secrets."cloudflare.include".path;
              username = "alexgate.dpdns.org";
              hostname = [
                "ipv6.awg.${hostName}.alexgate.dpdns.org"
                "awg.${hostName}.alexgate.dpdns.org"
              ];
              ssl = true;
              checkip-command = ''
                ${pkgs.iproute2}/bin/ip -6 addr show dev awg0 | ${pkgs.ripgrep}/bin/rg inet6 | ${pkgs.gawk}/bin/awk -F '[ ]+|/' '{print $3}'
              '';
              proxied = false;
            };
            "cloudflare.com:3" = {
              include = config.age.secrets."cloudflare.include".path;
              username = "alexgate.dpdns.org";
              hostname = [
                "ipv4.awg.${hostName}.alexgate.dpdns.org"
                "awg.${hostName}.alexgate.dpdns.org"
              ];
              ssl = true;
              checkip-command = ''
                ${pkgs.iproute2}/bin/ip -4 addr show dev awg0 | ${pkgs.ripgrep}/bin/rg inet | ${pkgs.gawk}/bin/awk -F '[ ]+|/' '{print $3}'
              '';
              proxied = false;
            };
          };
        };

        systemd.targets."wireguard-awg0".wantedBy = lib.mkForce [ ];

        systemd.services = lib.mkMerge (
          [
            {
              # 停止 Target 時也停止 Interface
              "wireguard-awg0".partOf = [
                "wireguard-awg0.target"
              ];
            }
          ]
          ++ builtins.map (p: {
            # 停止 Target 時也停止 DDNS refresh
            "wireguard-awg0-peer-${p}-refresh".partOf = [
              "wireguard-awg0.target"
            ];
          }) peers
        );

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
      inherit (config.initConfig.topo.${hostName}) id;
      peers = config.initConfig.topo.${hostName}.awgPeers;
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
          endpoint = "${p}.alexgate.dpdns.org:51820";
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
        # age.secrets."cloudflare.env".file = ../../../secrets/cloudflare.age;
        age.secrets."cloudflare.include" = {
          file = ../../../secrets/cloudflare-inadyn.age;
          owner = "inadyn";
          group = "inadyn";
        };

        services.inadyn = {
          enable = true;
          settings.allow-ipv6 = true;
          interval = "*:0/2";
          settings.provider = {
            "cloudflare.com:2" = {
              include = config.age.secrets."cloudflare.include".path;
              username = "alexgate.dpdns.org";
              hostname = [
                "ipv6.awg.${hostName}.alexgate.dpdns.org"
                "awg.${hostName}.alexgate.dpdns.org"
              ];
              ssl = true;
              checkip-command = ''
                ${pkgs.iproute2}/bin/ip -6 addr show dev awg0 | ${pkgs.ripgrep}/bin/rg inet6 | ${pkgs.gawk}/bin/awk -F '[ ]+|/' '{print $3}'
              '';
              proxied = false;
            };
            "cloudflare.com:3" = {
              include = config.age.secrets."cloudflare.include".path;
              username = "alexgate.dpdns.org";
              hostname = [
                "ipv4.awg.${hostName}.alexgate.dpdns.org"
                "awg.${hostName}.alexgate.dpdns.org"
              ];
              ssl = true;
              checkip-command = ''
                ${pkgs.iproute2}/bin/ip -4 addr show dev awg0 | ${pkgs.ripgrep}/bin/rg inet | ${pkgs.gawk}/bin/awk -F '[ ]+|/' '{print $3}'
              '';
              proxied = false;
            };
            "cloudflare.com:4" = {
              include = config.age.secrets."cloudflare.include".path;
              username = "alexgate.dpdns.org";
              hostname = [
                "ipv6.${hostName}.alexgate.dpdns.org"
                "${hostName}.alexgate.dpdns.org"
              ];
              ssl = true;
              checkip-command = ''
                ${pkgs.curl}/bin/curl -s -6 ifconfig.me/ip
              '';
              proxied = false;
            };
            "cloudflare.com:5" = {
              include = config.age.secrets."cloudflare.include".path;
              username = "alexgate.dpdns.org";
              hostname = [
                "ipv4.${hostName}.alexgate.dpdns.org"
                "${hostName}.alexgate.dpdns.org"
              ];
              ssl = true;
              checkip-command = ''
                ${pkgs.curl}/bin/curl -s -4 ifconfig.me/ip
              '';
              proxied = false;
            };
          };
        };

        # services.cloudflare-ddns = {
        #   enable = true;
        #   ip4Domains = [
        #     "ipv4.${hostName}.alexgate.dpdns.org"
        #     "${hostName}.alexgate.dpdns.org"
        #   ];
        #   ip6Domains = [
        #     "ipv6.${hostName}.alexgate.dpdns.org"
        #     "${hostName}.alexgate.dpdns.org"
        #   ];
        #   credentialsFile = config.age.secrets."cloudflare.env".path;
        #   updateCron = "@every 5m";
        # };

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
          peers = peerConf ++ [
            ({
              name = "fw13";
              publicKey = builtins.readFile ../../../secrets/awg/fw13.pub;
              allowedIPs = [
                "10.88.0.7/32"
                "fd88:88::7/128"
              ];
              persistentKeepalive = 25;
              dynamicEndpointRefreshRestartSeconds = 10;
            })
            ({
              name = "pixel7a";
              publicKey = builtins.readFile ../../../secrets/awg/pixel7a.pub;
              allowedIPs = [
                "10.88.0.101/32"
                "fd88:88::101/128"
              ];
              persistentKeepalive = 25;
              dynamicEndpointRefreshRestartSeconds = 10;
            })
          ];
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
