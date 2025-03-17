{ pkgs, userConfig, config, lib, ... }:
let
  inherit (config.networking) hostName;
  domainName = "alex${hostName}.duckdns.org";
  ddtokenName = "ddtoken_${hostName}";
in
{
  users.extraUsers."vaultwarden" = {
    isSystemUser = true;
    group = "vaultwarden";
    extraGroups = [ "acme" ];
  };
  users.extraGroups."vaultwarden" = { };
  age.secrets."vaultwarden.env" = {
    file = ../../secrets/env_vaultwarden_${hostName}.age;
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "600";
  };
  age.secrets."${ddtokenName}" = {
    file = ../../secrets/${ddtokenName}.age;
    owner = "acme";
    group = "acme";
    mode = "600";
  };
  environment.systemPackages = with pkgs; [
    vaultwarden
  ];

  # services.tailscale.permitCertUid = config.services.caddy.user;

  # networking.firewall.allowedTCPPorts = [4567 3306];
  # networking.firewall.allowedUDPPorts = [3306];
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.galera = {
      wsrep_provider = "${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so";
      wsrep_cluster_address = "gcomm://acer-tp,alexrpi4tp,oracle";
      binlog_format = "ROW";
      wsrep_on = "ON";
      default_storage_engine = "InnoDB";
      innodb_doublewrite = 1;
      wsrep_cluster_name = "galera";
      wsrep_node_address = hostName;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "alexlee800121@gmail.com";
  };
  security.acme.certs."${domainName}" = {
    dnsProvider = "duckdns";
    # dnsResolver = "100.100.100.100:53";
    # dnsPropagationCheck = false;
    dnsPropagationCheck = true;
    domain = domainName;
    extraDomainNames = [ "*.${domainName}" ];
    credentialFiles."DUCKDNS_TOKEN_FILE" = config.age.secrets."${ddtokenName}".path;
    credentialFiles."DUCKDNS_PROPAGATION_TIMEOUT_FILE" = pkgs.writeText "dd_prop_timeout" "600";
  };
  services.caddy.enable = true;
  services.caddy.virtualHosts."vaultwarden.${domainName}" = {
    useACMEHost = domainName;
    extraConfig = ''
      # tls {
      #   get_certificate tailscale
      # }
      # redir /vaultwarden /vaultwarden/
      # handle_path /vaultwarden/* {
      #   reverse_proxy /* http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
      # }
      reverse_proxy http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };
  services.vaultwarden.enable = true;
  services.vaultwarden.environmentFile = config.age.secrets."vaultwarden.env".path;
  services.vaultwarden.backupDir = "/var/backup/vaultwarden";
  services.vaultwarden.config = {
    # DISABLE_ADMIN_TOKEN = false;
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = "8000";
  };
}
