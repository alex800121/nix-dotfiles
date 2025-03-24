{
  oracle2 = {
    system = "aarch64-linux";
    kernelVersion = "6_12";
    userConfig = {
      hostName = "oracle2";
      userName = "alex800121";
      fontSize = 11.5;
      autoLogin = true;
    };
    extraModules = [
      ./oracle.nix
      ../hardware/oracle2.nix
    ];
    hmModules = [
      ../home/minimal.nix
      ../programs/nvim/minimal.nix
    ];
  };
  oracle = {
    system = "aarch64-linux";
    kernelVersion = "6_12";
    userConfig = {
      hostName = "oracle";
      userName = "alex800121";
      fontSize = 11.5;
      autoLogin = true;
      borgbackupRepo = [
        {
          repoName = "vaultwarden";
          subRepo = true;
          clients = [ "alexrpi4tp" ];
        }
      ];
    };
    extraModules = [
      ./oracle.nix
      ../hardware/oracle.nix
    ];
    hmModules = [
      ../home/minimal.nix
      ../programs/nvim/minimal.nix
    ];
  };
  alexrpi4tpmin = {
    system = "aarch64-linux";
    kernelVersion = "rpi4";
    userConfig = {
      hostName = "alexrpi4tp";
      userName = "alex800121";
      fontSize = 11.5;
      autoLogin = true;
    };
    extraModules = [
      ./alexrpi4tpmin.nix
    ];
    hmModules = [
      ../home/rpi4.nix
    ];
  };
  alexrpi4tp = {
    system = "aarch64-linux";
    kernelVersion = "rpi4";
    userConfig = {
      hostName = "alexrpi4tp";
      userName = "alex800121";
      fontSize = 11.5;
      autoLogin = true;
      url = "alexrpi4gate";
      port = 30000;
    };
    extraModules = [
      ./alexrpi4tp.nix
    ];
    hmModules = [
      ../home/rpi4.nix
      ../programs/nvim
    ];
  };
  acer-tp = {
    system = "x86_64-linux";
    kernelVersion = "6_12";
    userConfig = {
      hostName = "acer-tp";
      userName = "alex800121";
      fontSize = 16;
      autoLogin = true;
      url = "alexacer-tp";
      port = 31000;
      borgbackupRepo = [
        {
          repoName = "vaultwarden";
          subRepo = true;
          clients = [ "alexrpi4tp" ];
        }
      ];
    };
    extraModules = [
      ./acer-tp.nix
    ];
    hmModules = [
      ../home
      ../programs/nvim
    ];
  };
  fw13-musnix =
    {
      system = "x86_64-linux";
      kernelVersion = "6_12";
      userConfig = {
        hostName = "fw13";
        userName = "alex800121";
        fontSize = 12;
        autoLogin = false;
        port = 32000;
        soundcardPciId = "c1:00.6";
      };
      extraModules = [
        ./fw13.nix
        ./musnix.nix
        ./linux-rt.nix
      ];
      hmModules = [
        ../home
        ../programs/nvim
      ];
    };
  fw13 =
    {
      system = "x86_64-linux";
      kernelVersion = "6_12";
      userConfig = {
        hostName = "fw13";
        userName = "alex800121";
        fontSize = 12;
        autoLogin = false;
        port = 32000;
        soundcardPciId = "c1:00.6";
      };
      extraModules = [
        ./fw13.nix
      ];
      hmModules = [
        ../home
        ../programs/nvim
      ];
    };
}
