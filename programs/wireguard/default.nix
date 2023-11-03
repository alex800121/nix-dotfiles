{ pkgs, config, userConfig, ... }: {
  environment.systemPackages = [ pkgs.wireguard-tools ];
  systemd.network = {
    enable = true;
  };
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
}
