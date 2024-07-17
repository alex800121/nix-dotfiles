{ pkgs, inputs, nixpkgsUnstable, ... }:
let
  inherit (pkgs) system;
in
{
  # services.dnsmasq = {
  #   enable = true;
  #   settings = {
  #     interface = "virbr0";
  #   };
  #   alwaysKeepRunning = true;
  #   resolveLocalQueries = true;
  # };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [
          pkgs.OVMFFull.fd
          # pkgs.pkgsCross.aarch64-multiplatform.OVMFFull.fd
        ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  virtualisation.lxd.enable = true;

  services.spice-vdagentd.enable = true;
  environment.systemPackages = with nixpkgsUnstable; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];
}
