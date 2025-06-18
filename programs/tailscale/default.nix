{ config, userConfig, ... }: {
  services.tailscale.enable = true;

  services.tailscale.openFirewall = true;

  networking.firewall.trustedInterfaces = [
    config.services.tailscale.interfaceName
  ];

  age.secrets."tsauth" = {
    file = ../../secrets/tsauth.age;
  };

  services.tailscale.authKeyFile = config.age.secrets."tsauth".path;
  services.tailscale.extraUpFlags = [
    "--reset"
  ];

  services.tailscale.extraSetFlags = [
    "--operator=${userConfig.userName}"
  ];
}
