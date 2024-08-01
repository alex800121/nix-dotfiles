{ pkgs, lib, userConfig, inputs, kernelVersion, ... }: let
  inherit (userConfig) userName hostName;
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
  networking.firewall.allowedTCPPorts = [
    30000
    31000
  ];
  networking.firewall.allowedUDPPorts = [
    30000
    31000
  ];
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      UseDns = true;
      PermitRootLogin = "prohibit-password";
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaSD3qsWtMBdadX2256X+2xBl4O3//d/vGUKBxgCTyR root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICF22WQW3bhm7MpPR9Ye3SFDudNJ6XdXgEqSIrE7Cv33 root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICid1/VEdjJct9RWaL4Hz+igBnu185ySy8kuAxVHZGyN alex800121@m1-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFte0h3WjujSOGEUOiD/ruFXMatUobyFJmmpD0iXD8Jy root@m1-nixos"
  ];
}
