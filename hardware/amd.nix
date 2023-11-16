{ config, lib, pkgs, modulesPath, ... }:
{
  hardware.amdgpu.loadInInitrd = true;
  hardware.amdgpu.amdvlk = false;
  hardware.amdgpu.opencl = true;
}
