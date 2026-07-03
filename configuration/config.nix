{
  oracle3 = {
    userConfig = {};
    extraModules = [
      ./oracle3.nix
    ];
    hmModules = [
      ../programs/nvim/minimal.nix
    ];
  };
  oracle2 = {
    userConfig = {};
    extraModules = [
      ./oracle2.nix
    ];
    hmModules = [
      ../programs/nvim/minimal.nix
    ];
  };
  oracle = {
    userConfig = {
      tailscale = {
        peers = [ 2 3 ];
      };
      keepalived.routers = [
        {
          id = 1;
          priority = 0;
        }
      ];
    };
    extraModules = [
      ./oracle.nix
    ];
    hmModules = [
      ../programs/nvim/minimal.nix
    ];
  };
  alexrpi4tpmin = {
    userConfig = {};
    extraModules = [
      ./alexrpi4tpmin.nix
    ];
    hmModules = [
      ../home/rpi4.nix
    ];
  };
  alexrpi4tp = {
    userConfig = {
      keepalived.routers = [
        {
          id = 1;
          priority = 1;
        }
      ];
    };
    extraModules = [
      ./alexrpi4tp.nix
    ];
    hmModules = [
      ../programs/nvim/minimal.nix
    ];
  };
  acer-tp = {
    userConfig = {
      keepalived.routers = [
        {
          id = 1;
          priority = 2;
        }
      ];
    };
    extraModules = [
      ./acer-tp.nix
    ];
    hmModules = [
      ../programs/nvim
    ];
  };
  fw13-musnix = {
    userConfig = {};
    extraModules = [
      ./fw13-musnix.nix
    ];
    hmModules = [
      ../programs/nvim
    ];
  };
  fw13 = {
    userConfig = {};
    extraModules = [
      ./fw13.nix
    ];
    hmModules = [
      ../programs/nvim
    ];
  };
}
