self: super: {
  microsoft-edge = super.microsoft-edge.overrideAttrs (old: {
    postFixup = (self.lib.strings.removeSuffix "\n" old.postFixup) + " " + ''\
  --append-flags --ozone-platform=wayland \
  --append-flags --enable-wayland-ime
    '';
  });
}
