{
  flake.nixosModules.acme-gate =
    { pkgs, config, ... }:
    let
      duckGate = "alexgate.duckdns.org";
      duckToken = "ddtoken";
      cloudGate = "alexgate.dpdns.org";
      cloudToken = "cloudflare";
    in
    {
      age.secrets."${duckToken}" = {
        file = ../../../secrets/${duckToken}.age;
        owner = "acme";
        group = "acme";
        mode = "600";
      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "alexlee800121@gmail.com";
      };
      security.acme.certs."${duckGate}" = {
        dnsProvider = "duckdns";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        domain = duckGate;
        extraDomainNames = [ "*.${duckGate}" ];
        environmentFile = config.age.secrets."${duckToken}".path;
        credentialFiles = {
          "DUCKDNS_PROPAGATION_TIMEOUT_FILE" = pkgs.writeText "dd-prop-timeout" "600";
          "DUCKDNS_SEQUENCE_INTERVAL_FILE" = pkgs.writeText "dd-sequence-interval" "60";
        };
      };
    };
}
