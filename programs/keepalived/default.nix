{ config, userConfig, ... }: {
  services.keepalived = {
    enable = true;
    vrrpInstances."virt0" = {
      state = "MASTER";
      priority = 100;
      interface = "eth0";
      virtualIps = [
        {
          addr = "192.168.50.1/24";
          label = "eth0:v0";
        }
      ];
      virtualRouterId = 1;
    };
  };
}
