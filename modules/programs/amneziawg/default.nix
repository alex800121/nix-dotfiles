{ inputs, ... }: {
  flake.nixosModules.amneziawg-client =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
    };
  flake.nixosModules.amneziawg-server =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # AmneziaWG server
      networking.wg-quick.interfaces.awg0 = {
        type = "amneziawg";
        autostart = true;
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
        externalInterface = "ens3";
        internalInterfaces = [ "awg0" ];
      };
    };
}
