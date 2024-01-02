
{ pkgs, inputs, ... }: let
  nixpkgsUnstable = import inputs.nixpkgsUnstable { inherit system; config.allowUnfree = true; };
  inherit (pkgs) system;
in {
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
        ovmf.packages = [ pkgs.OVMFFull.fd pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  virtualisation.lxd.enable = true;

  services.spice-vdagentd.enable = true;
  environment.systemPackages = [
    nixpkgsUnstable.virt-manager
    nixpkgsUnstable.virt-viewer
    nixpkgsUnstable.spice 
    nixpkgsUnstable.spice-gtk
    nixpkgsUnstable.spice-protocol
    nixpkgsUnstable.win-virtio
    nixpkgsUnstable.win-spice
  ];
}
