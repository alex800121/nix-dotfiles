{ pkgs, lib, userConfig, inputs, kernelVersion, ... }: let
  inherit (userConfig) userName hostName;
in {
  programs.ssh = {
    startAgent = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      UseDns = true;
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      GatewayPorts = "yes";
      # GatewayPorts = "clientspecified";
      X11Forwarding = true;
    };
    extraConfig = ''
      PermitTunnel yes
      PermitTTY yes
      AllowStreamLocalForwarding yes
      AllowTcpForwarding yes
    '';
    allowSFTP = true;
  };
  users.users."${userName}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARVVshQ9ZOtGRPIWensN5uP9nWE3tOI0Ojr6gX5ZaYq ed"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZLAWYLkwEtjlj2e65MwoDOLWUKJBBrjeDf4K0CcuIz alex800121@DaddyAlexAsus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxDNBfYv0w8MLJOLK2nn2kmEpH20G8Y0Mauw9GMHvda alex800121@DaddyAlexAsus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEydwYcKvthPPxPt4P7YkzUgzHahKk/gAMUv7py/jeCN alex800121@acer-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEelyNLu6y1owoChvv/BfkI4LytFnb7QCyDWPNDAywc alexanderlee800121@cs-458534110940-default"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaDVZZM189JmJc4uiR77DhzqsZ4u5UVtpcH33IR/YW4 alex800121@ipadair"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/FOfzUF0nSno+780hSUGX1bDPqmfZpEUG0f/imEl3r alex800121@alexrpi4dorm"
  ];
}
