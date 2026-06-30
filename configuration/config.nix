{
  oracle3 = {
    userConfig = {
      tailscale = {
        id = 5;
      };
    };
    extraModules = [
      ./oracle3.nix
    ];
    hmModules = [
      ../programs/nvim/minimal.nix
    ];
  };
  oracle2 = {
    userConfig = {
      tailscale = {
        id = 6;
      };
    };
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
        id = 4;
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
      ./ssh-serve.nix
      (import ../programs/borgbackup/vaultwarden.nix [ "acer-tp" ])
      ../programs/vaultwarden
    ];
    hmModules = [
      ../programs/nvim/minimal.nix
    ];
  };
  alexrpi4tpmin = {
    kernelVersion = "6_18";
    extraModules = [
      ./alexrpi4tpmin.nix
    ];
    hmModules = [
      ../home/rpi4.nix
    ];
  };
  alexrpi4tp = {
    kernelVersion = "6_18";
    userConfig = {
      tailscale = {
        id = 2;
        peers = [ 3 4 ];
      };
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
    kernelVersion = "6_18";
    userConfig = {
      borgbackupRepo = [
        {
          repoName = "vaultwarden";
          clients = [ "oracle" "alexrpi4tp" ];
        }
      ];
      tailscale = {
        id = 3;
        peers = [ 2 4 ];
      };
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
    kernelVersion = "6_18";
    userConfig = {
      soundcardPciId = "c1:00.6";
    };
    extraModules = [
      ./fw13.nix
      ./musnix.nix
      ./linux-rt.nix
    ];
    hmModules = [
      ../programs/nvim
    ];
  };
  fw13 = {
    kernelVersion = "6_18";
    userConfig = {
      soundcardPciId = "c1:00.6";
    };
    extraModules = [
      ./fw13.nix
    ];
    hmModules = [
      ../programs/nvim
    ];
  };
}
