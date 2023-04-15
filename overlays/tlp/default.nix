self: super: {
  tlp = super.tlp.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "TLP";
      rev = "eb904bdd733b5ffd0c7a3b46a66c138d41654221";
      sha256 = "sha256-qUll3vV8zaXN0clLFotAX9sFL9FWbfQQnxuJHX5jZ8E=";
    };
    patches = [ ./patches/custom_patch.patch ];
  });
}
