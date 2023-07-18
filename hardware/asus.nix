# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  # boot.kernelModules = [ "kvm-amd" "amd-pstate" ];
  # boot.kernelParams = [ 
  #   "initcall_blacklist=acpi_cpufreq_init" 
  #   "amd_pstate.shared_mem=1"
  #   "amd_pstate=active" 
  #   "amdgpu.sg_display=0" 
  # ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/bc490d14-3c57-4da1-99b2-6c8e11aa9ee2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C033-F4B9";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/2f13de69-409e-4116-ba72-243f93e6c887"; }
  ];

  # fileSystems."/media/alex800121/Asus" = {
  #   device = "/dev/disk/by-uuid/AC6E34966E345B72";
  #   fsType = "ntfs";
  #   options = [ "rw" "uid=1000" ];
  # };
  #
  # fileSystems."/home/alex800121/OneDrive" = {
  #   device = "/media/alex800121/Asus/Users/alex800121/OneDrive/";
  #   options = [ "bind" ];
  # };

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "suspend";
    killUserProcesses = false;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.amdgpu.loadInInitrd = true;
  hardware.amdgpu.amdvlk = false;
  hardware.amdgpu.opencl = true;
}
