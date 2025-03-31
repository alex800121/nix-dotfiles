{ lib, pkgs, config, ... }:
let
  ddtokenName = "ddtoken_${config.networking.hostName}";
  init =
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
    };
in
lib.foldl'
  (acc: hostName:
  let
    domainName = "alex${hostName}.duckdns.org";
  in
  lib.recursiveUpdate acc {
    security.acme.certs."${domainName}" = {
      dnsProvider = "duckdns";
      dnsResolver = "1.1.1.1:53";
      # dnsPropagationCheck = true;
      dnsPropagationCheck = false;
      domain = domainName;
      extraDomainNames = [ "*.${domainName}" ];
      credentialFiles."DUCKDNS_TOKEN_FILE" = config.age.secrets."${ddtokenName}".path;
      credentialFiles."DUCKDNS_PROPAGATION_TIMEOUT_FILE" = pkgs.writeText "dd_prop_timeout" "600";
      credentialFiles."DUCKDNS_TTL_FILE" = pkgs.writeText "dd_ttl" "200";
    };
  })
  init [ "acer-tp" "alexrpi4tp" "oracle" "fw13" ]
