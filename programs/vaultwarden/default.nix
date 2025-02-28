{ pkgs, userConfig, config, ... }: {
  environment.systemPackages = with pkgs; [
    vaultwarden
  ];
  services.tailscale.permitCertUid = config.services.caddy.user;
  services.caddy.enable = true;
  services.caddy.virtualHosts."${userConfig.hostName}.taildaa926.ts.net:8001" = {
    extraConfig = ''
      tls {
        get_certificate tailscale
      }
      # redir /vaultwarden /vaultwarden/
      # handle_path /vaultwarden/* {
      #   reverse_proxy /* http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
      # }
      reverse_proxy http://localhost:${config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };
  services.vaultwarden.enable = true;
  services.vaultwarden.config = {
    # DISABLE_ADMIN_TOKEN = false;
    # ADMIN_TOKEN = "ZnM+TUjtFDXs+LVXsmz+XSLknTTkIAmi92pR0f6iQ0r8cvFKSnfgQ+OtcTuQJiNm";
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = "8000";
  };
}
