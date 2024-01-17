{ config, lib, pkgs, modulesPath, ... }:
{
  hardware.amdgpu.loadInInitrd = true;
  hardware.amdgpu.amdvlk = true;
  hardware.amdgpu.opencl = true;
}
