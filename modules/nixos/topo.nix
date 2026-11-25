{
  flake.nixosModules.topo =
    { lib, config, ... }:
    {
      config.initConfig.topo = {
        fw12 = {
          id = 9;
          awgPeers = [
            "oracle"
          ];
        };
        fw13 = {
          id = 7;
          awgPeers = [
            "oracle"
          ];
        };
        alexrpi4tp = {
          id = 2;
          awgPeers = [
            "acer-tp"
            "oracle"
            "oracle4"
          ];
          peers = [
            "acer-tp"
            "oracle"
          ];
          keepalived = {
            router = {
              id = 1;
              priority = 1;
            };
          };
        };
        acer-tp = {
          id = 3;
          awgPeers = [
            "oracle"
            "alexrpi4tp"
            "oracle4"
          ];
          peers = [
            "oracle"
            "alexrpi4tp"
          ];
          keepalived = {
            router = {
              id = 1;
              priority = 2;
            };
          };
        };
        oracle = {
          id = 4;
          awgPeers = [
            "acer-tp"
            "alexrpi4tp"
            "oracle4"
          ];
          peers = [
            "acer-tp"
            "alexrpi4tp"
          ];
          keepalived = {
            router = {
              id = 1;
              priority = 0;
            };
          };
        };
        oracle2 = {
          id = 5;
        };
        oracle3 = {
          id = 6;
        };
        oracle4 = {
          id = 8;
          awgPeers = [
            "acer-tp"
            "alexrpi4tp"
            "oracle"
          ];
        };
      };
    };
}
