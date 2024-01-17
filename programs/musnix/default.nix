{ pkgs, ... }: {
   security.pam.loginLimits = [
      { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
      { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
      { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
    ];
    musnix = {
      enable = true;
      alsaSeq.enable = true;
      soundcardPciId = "63:00.6";
      kernel.realtime = true;
      kernel.packages = pkgs.linuxPackages_6_6_rt;
    };
}
