{ inputs, ... }:
{
  flake.nixosModules.xray-server =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
      config = {
        age.secrets."xray-server.json" = {
          file = ../../../secrets/xray-server-${config.networking.hostName}.age;
        };

        services.xray = {
          enable = true;
          settingsFile = config.age.secrets."xray-server.json".path;
        };

        networking.firewall.allowedTCPPorts = [ 443 ];
      };
    };
  flake.nixosModules.xray-client =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
      config = { };
    };
}
