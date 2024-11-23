{ pkgs, nixpkgsUnstable, ... }: {
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.package = nixpkgsUnstable.vmware-workstation;
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
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];
}
