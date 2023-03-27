self: super:
{
  x-air-edit = super.callPackage ./x-air-edit.nix {};
  # pulseaudioFull = super.pulseaudioFull.override { advancedBluetoothCodecs = true; };
}
