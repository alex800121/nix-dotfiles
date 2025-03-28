{ pkgs, config, ... }:
let
  inherit (config.networking) hostName;
  gateName = "alexgate.duckdns.org";
  ddtokenName = "ddtoken_${hostName}";
in
{
  age.secrets."${ddtokenName}" = {
    file = ../../secrets/${ddtokenName}.age;
    owner = "acme";
    group = "acme";
    mode = "600";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "alexlee800121@gmail.com";
  };
  security.acme.certs."${gateName}" = {
    dnsProvider = "duckdns";
    dnsResolver = "8.8.8.8:53";
    dnsPropagationCheck = true;
    domain = gateName;
    extraDomainNames = [ "*.${gateName}" ];
    credentialFiles."DUCKDNS_TOKEN_FILE" = config.age.secrets."${ddtokenName}".path;
    credentialFiles."DUCKDNS_PROPAGATION_TIMEOUT_FILE" = pkgs.writeText "dd_prop_timeout" "600";
  };
}
