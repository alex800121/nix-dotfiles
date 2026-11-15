{
  flake.nixosModules.acme-gate =
    { pkgs, config, ... }:
    let
      gateName = "alexgate.duckdns.org";
      ddtokenName = "ddtoken";
    in
    {
      age.secrets."${ddtokenName}" = {
        file = ../../../secrets/${ddtokenName}.age;
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
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        domain = gateName;
        extraDomainNames = [ "*.${gateName}" ];
        environmentFile = config.age.secrets."${ddtokenName}".path;
        # credentialFiles."DUCKDNS_TOKEN_FILE" = config.age.secrets."${ddtokenName}".path;

        credentialFiles = {
          "DUCKDNS_PROPAGATION_TIMEOUT_FILE" = pkgs.writeText "dd-prop-timeout" "600";

          "DUCKDNS_SEQUENCE_INTERVAL_FILE" = pkgs.writeText "dd-sequence-interval" "60";
        };
      };
    };
}
