{ pkgs, config, lib, ... }:
let
  inherit (config.networking) hostName;
  domainName = "alex${hostName}.duckdns.org";
  port = config.services.mysql.settings.mysqld.port;
  dataDir = config.services.mysql.settings.mysqld.datadir;
  sslDir = config.security.acme.certs."${domainName}".directory;
  myCnfPath = "/var/lib/my.cnf";
  myCnfFile = pkgs.writeText "my.cnf" ''
    [galera]
    binlog_format=ROW
    default_storage_engine=InnoDB
    innodb_doublewrite=1
    wsrep_cluster_address=gcomm://acer-tp,alexrpi4tp,oracle
    wsrep_cluster_name=galera
    wsrep_node_address=@TAILSCALE_IP@
    wsrep_on=ON
    wsrep_provider=${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so
    wsrep_sst_method=rsync

    [mysqld]
    datadir=${dataDir}
    port=${builtins.toString port}
  '';
in
{
  imports = [ ../acme ];

  users.extraUsers."vaultwarden" = {
    isSystemUser = true;
    group = "vaultwarden";
    # extraGroups = [ config.security.acme.certs."${domainName}".group ];
  };

  users.extraGroups."vaultwarden" = { };
  age.secrets."vaultwarden.env" = {
    file = ../../secrets/env_vaultwarden_${hostName}.age;
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "600";
  };
  environment.systemPackages = with pkgs; [
    vaultwarden
  ];

  # services.tailscale.permitCertUid = config.services.caddy.user;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    configFile = myCnfPath;
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
  };

  systemd.services.mysql-ip-set = {
    serviceConfig.type = "oneshot";
    requiredBy = [ "mysql.service" ];
    before = [ "mysql.service" ];
    requires = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];
    path = with pkgs; [ tailscale gnused coreutils ];
    script = ''
      cp ${myCnfFile} ${myCnfPath}
      sed -i "s/@TAILSCALE_IP@/$(tailscale ip | head -1)/" ${myCnfPath}
    '';
  };
  systemd.services.mysql.requires = [ "mysql-ip-set.service" ];
  systemd.services.mysql.after = [ "mysql-ip-set.service" ];
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
  users.users."${config.services.caddy.user}".extraGroups = [ config.security.acme.certs."${domainName}".group ];
  services.caddy.virtualHosts."vaultwarden.${domainName}" = {
    # useACMEHost = domainName;
    extraConfig = ''
      tls ${sslDir}/cert.pem ${sslDir}/key.pem
      reverse_proxy http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };

  services.vaultwarden.enable = true;
  services.vaultwarden.environmentFile = config.age.secrets."vaultwarden.env".path;
  services.vaultwarden.backupDir = "/var/backup/vaultwarden";
  services.vaultwarden.config = {
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = "8000";
  };
}
