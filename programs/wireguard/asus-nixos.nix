{ pkgs, userConfig, ... }:
let
  port = 50541;
in
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    nftables
  ];
  services.avahi = {
    allowPointToPoint = true;
    reflector = true;
    allowInterfaces = [
      "lo"
      userConfig.hostName
    ];
  };
  networking.firewall = {
    allowedTCPPorts = [
      53
    ];
    allowedUDPPorts = [
      53
      port
    ];
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport ${toString port} -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport ${toString port} -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport ${toString port} -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport ${toString port} -j RETURN || true
    '';
  };
}
