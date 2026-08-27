{
  flake.nixosModules.topo =
    { lib, config, ... }:
    {
      config.initConfig.topo = {
        alexrpi4tp = {
          id = 2;
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
      };
    };
}
