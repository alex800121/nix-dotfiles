{ ... }:
{
  imports = [
    ./fw13.nix
    ./musnix.nix
    ./linux-rt.nix
  ];

  musnix.soundcardPciId = "c1:00.6";
}
