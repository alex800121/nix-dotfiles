{ pkgs, config, userConfig, lib, ... }:
let
  inherit (config.networking) hostName;
  inherit (userConfig.keepalived) routers;
  inherit (builtins) toString;
  inherit (userConfig.tailscale) id;
  dbHosts = [ "acer-tp" "alexrpi4tp" "oracle" "oracle2" "oracle3" ];
  tsIp = "100.64.0.${toString id}";
  domainName = "alex${hostName}.duckdns.org";
  vwName = "vw.${domainName}";
  gateName = "alexgate.duckdns.org";
  vwGateName = "vw.${gateName}";
  port = config.services.mysql.settings.mysqld.port;
in
{
  imports = [
    ../acme
    ../acme/gate.nix
    ../keepalived/vaultwarden.nix
  ];

  users.extraUsers."vaultwarden".isSystemUser = true;
  users.extraUsers."vaultwarden".group = "vaultwarden";

  users.extraGroups."vaultwarden" = { };
  age.secrets."vaultwarden.env" = {
    file = ../../secrets/env_vaultwarden.age;
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
    settings = {
      galera = {
        binlog_format = "ROW";
        default_storage_engine = "InnoDB";
        innodb_doublewrite = 1;
        wsrep_cluster_address = "gcomm://${lib.concatStringsSep "," dbHosts}";
        wsrep_cluster_name = "galera";
        wsrep_node_address = tsIp;
        wsrep_on = "ON";
        wsrep_provider = "${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so";
        wsrep_sst_method = "rsync";
      };
      mysqld = {
        bind_address = "127.0.0.1";
      };
    };
  };
  systemd.services.mysql.wants = [ "tailscale-server-ip.service" "network-online.target" "tailscaled.service" ];
  systemd.services.mysql.after = [ "tailscale-server-ip.service" "network-online.target" "tailscaled.service" ];
  systemd.services.mysql.requires = [ "tailscale-server-ip.service" "network-online.target" "tailscaled.service" ];
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

  services.tailscale.extraSetFlags = [
    "--advertise-routes=${lib.concatMapStringsSep "," (x: "192.168.101.${toString x.id}/32") routers}"
  ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  services.caddy.virtualHosts."${vwName}" = {
    useACMEHost = domainName;
    extraConfig = ''
      reverse_proxy http://${config.services.vaultwarden.config.ROCKET_ADDRESS}:${config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };

  services.caddy.virtualHosts."${vwGateName}" = {
    useACMEHost = gateName;
    extraConfig = ''
      reverse_proxy http://${config.services.vaultwarden.config.ROCKET_ADDRESS}:${config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };
}
