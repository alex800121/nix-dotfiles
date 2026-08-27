{ self, ... }: {
  flake.nixosModules.vaultwarden =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (builtins) toString;
      gateName = "alexgate.duckdns.org";
      vwGateName = "vw.${gateName}";
      port = config.services.mysql.settings.mysqld.port;
    in
    {
      imports = [
        self.nixosModules.acme-gate
        self.nixosModules.keepalived-vaultwarden
      ];

      options = {
        services.vaultwarden.galera.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        services.vaultwarden.galera.tailscale.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        services.vaultwarden.galera.peers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = config.initConfig.topo."${config.networking.hostName}".peers or [ ];
        };
        services.vaultwarden.galera.ip = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = config.services.tailscale.server.ip or null;
        };
      };

      config = lib.mkMerge [
        (lib.mkIf config.services.vaultwarden.galera.enable {
          assertions = [
            {
              assertion = config.services.vaultwarden.galera.ip != null;
              message = "galera enabled. must set one of topo.nix/initConfig.id/services.tailscale.server.ip/services.vaultwarden.galera.ip";
            }
          ];
          services.mysql.settings.galera = {
            binlog_format = "ROW";
            default_storage_engine = "InnoDB";
            innodb_doublewrite = 1;
            wsrep_cluster_address = "gcomm://${lib.concatStringsSep "," config.services.vaultwarden.galera.peers}";
            wsrep_cluster_name = "galera";
            wsrep_node_address = config.services.vaultwarden.galera.ip;
            wsrep_on = "ON";
            wsrep_provider = "${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so";
            wsrep_sst_method = "rsync";
          };
        })
        (lib.mkIf config.services.vaultwarden.galera.tailscale.enable {
          systemd.services.mysql.wants = [
            "network-online.target"
            "tailscale-server-ip.service"
            "tailscaled.service"
          ];
          systemd.services.mysql.after = [
            "network-online.target"
            "tailscale-server-ip.service"
            "tailscaled.service"
          ];
          systemd.services.mysql.requires = [
            "network-online.target"
            "tailscale-server-ip.service"
            "tailscaled.service"
          ];
        })
        {
          users.extraUsers."vaultwarden".isSystemUser = true;
          users.extraUsers."vaultwarden".group = "vaultwarden";

          users.extraGroups."vaultwarden" = { };
          age.secrets."vaultwarden.env" = {
            file = ../../../secrets/env_vaultwarden.age;
            owner = "vaultwarden";
            group = "vaultwarden";
            mode = "600";
          };
          environment.systemPackages = with pkgs; [
            vaultwarden
          ];

          services.mysql = {
            enable = true;
            package = pkgs.mariadb;
            ensureUsers = [
              {
                name = "vaultwarden";
                ensurePermissions = {
                  "vaultwarden.*" = "ALL PRIVILEGES";
                };
              }
            ];
            ensureDatabases = [ "vaultwarden" ];
            initialDatabases = [
              {
                name = "vaultwarden";
                schema = pkgs.writeText "vaultwarden.sql" ''
                  ALTER DATABASE vaultwarden CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
                '';
              }
            ];
            settings.mysqld = {
              bind_address = "127.0.0.1";
            };
          };
          systemd.services.mysql.serviceConfig.Restart = lib.mkForce "on-failure";
          systemd.services.mysql.path = with pkgs; [
            mariadb
            bash
            gawk
            gnutar
            gzip
            inetutils
            iproute2
            netcat
            procps
            pv
            rsync
            socat
            stunnel
            which
          ];

          services.caddy.enable = true;

          systemd.services.vaultwarden.wantedBy = [ "mysql.service" ];
          systemd.services.vaultwarden.requires = [ "mysql.service" ];
          systemd.services.vaultwarden.after = [ "mysql.service" ];
          systemd.services.vaultwarden.bindsTo = [ "mysql.service" ];
          systemd.services.vaultwarden.serviceConfig.RestartSec = "10s";

          services.vaultwarden.enable = true;
          services.vaultwarden.dbBackend = "mysql";
          services.vaultwarden.environmentFile = config.age.secrets."vaultwarden.env".path;
          services.vaultwarden.config = {
            ROCKET_ADDRESS = "127.0.0.1";
            ROCKET_PORT = "8000";
            DATABASE_URL = "mysql://vaultwarden@localhost:${toString port}/vaultwarden";
            ENABLE_WEBSOCKET = true;
            PUSH_ENABLED = true;
            PUSH_RELAY_URI = "https://api.bitwarden.com";
            PUSH_IDENTITY_URI = "https://identity.bitwarden.com";
            DOMAIN = "https://${vwGateName}";
          };

          boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
          boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

          services.caddy.virtualHosts."${vwGateName}" = {
            useACMEHost = gateName;
            extraConfig = ''
              reverse_proxy http://${config.services.vaultwarden.config.ROCKET_ADDRESS}:${config.services.vaultwarden.config.ROCKET_PORT}
            '';
          };
        }
      ];
    };
}
