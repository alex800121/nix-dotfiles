{ pkgs, lib,... }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };
  services.pgadmin = {
    enable = true;
    initialEmail = "tmp@tmp.com";
    initialPasswordFile = pkgs.writeText "tmp_pw" "000000";
  };
}
