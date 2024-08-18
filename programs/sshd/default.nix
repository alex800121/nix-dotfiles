{ userConfig, lib, ... }: let
  inherit (userConfig) userName port;
in {
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host acer-tp
          Hostname alexacer-tp.duckdns.org
          Port 31000
      Host alexrpi4tp
          Hostname alexrpi4gate.duckdns.org
          Port 30000
    '';
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      UseDns = true;
      PermitRootLogin = lib.mkDefault "prohibit-password";
      PasswordAuthentication = false;
      # GatewayPorts = "yes";
      GatewayPorts = "clientspecified";
      X11Forwarding = false;
    };
    extraConfig = ''
      PermitTunnel yes
      PermitTTY yes
      AllowStreamLocalForwarding yes
      AllowTcpForwarding yes
      UsePAM no
    '';
    allowSFTP = true;
  };
  users.users."${userName}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaDVZZM189JmJc4uiR77DhzqsZ4u5UVtpcH33IR/YW4 alex800121@ipadair"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaSD3qsWtMBdadX2256X+2xBl4O3//d/vGUKBxgCTyR root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICF22WQW3bhm7MpPR9Ye3SFDudNJ6XdXgEqSIrE7Cv33 root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRQwxRtvgHlsGLfW4YzNqp1c+rVe7mveqOHh/EfdCUn alex800121@fw13"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6u5RCXsCrSxX3qxIZqZNRp/rZ1J4rTi2j9uxCXkUrn root@fw13"
  ];
}
