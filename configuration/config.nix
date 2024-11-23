{
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
    kernelVersion = "6_11";
    userConfig = {
      hostName = "acer-tp";
      userName = "alex800121";
      fontSize = 16;
      autoLogin = true;
      url = "alexacer-tp";
      port = 31000;
    };
    extraModules = [
      ./acer-tp.nix
    ];
    hmModules = [
      ../home
      ../programs/nvim
    ];
  };
  fw13-musnix = {
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
      ../configuration/musnix.nix
      ../configuration/linux-rt.nix
    ];
    hmModules = [
      ../home
      ../programs/nvim
    ];
  };
  fw13 = {
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
