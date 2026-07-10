{ ... }:
{
  imports =
    [
      ./oracleCommon.nix
      ./topo.nix
    ];

  initConfig.hostName = "oracle3";
}
