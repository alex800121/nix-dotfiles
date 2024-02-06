{ pkgs, lib, userConfig, inputs, kernelVersion, ... }: let
  inherit (userConfig) userName hostName;
in {
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host acer-tp
          Hostname alexacer-tp.duckdns.org
          Port 31000
      Host acer-nixos
          Hostname alexacer-tp.duckdns.org
          Port 51000
      Host alexrpi4dorm
          Hostname alexrpi4gate.duckdns.org
          Port 50000
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARVVshQ9ZOtGRPIWensN5uP9nWE3tOI0Ojr6gX5ZaYq ed"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZLAWYLkwEtjlj2e65MwoDOLWUKJBBrjeDf4K0CcuIz alex800121@DaddyAlexAsus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxDNBfYv0w8MLJOLK2nn2kmEpH20G8Y0Mauw9GMHvda alex800121@DaddyAlexAsus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEelyNLu6y1owoChvv/BfkI4LytFnb7QCyDWPNDAywc alexanderlee800121@cs-458534110940-default"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaDVZZM189JmJc4uiR77DhzqsZ4u5UVtpcH33IR/YW4 alex800121@ipadair"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf9DW0O5gkq0ephXxUl7SXgb6TMkAA7RgB9NIl4oKNi alex800121@nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEydwYcKvthPPxPt4P7YkzUgzHahKk/gAMUv7py/jeCN alex800121@acer-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/FOfzUF0nSno+780hSUGX1bDPqmfZpEUG0f/imEl3r alex800121@alexrpi4dorm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60v2orfSvgFBj2pAPdRTJHRWvHFlICIkUzKEsW4Erc root@asus-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxXK6xHqmWN/gumrcwzaSMk5AOeni/NGXnf2dul1Sax root@acer-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaSD3qsWtMBdadX2256X+2xBl4O3//d/vGUKBxgCTyR root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICF22WQW3bhm7MpPR9Ye3SFDudNJ6XdXgEqSIrE7Cv33 root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYMmkDdjmPFYFSPLLWWwoRD6cChs/zFozaHWfiaDsAA root@alexrpi4dorm"
  ];
}
