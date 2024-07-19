{ ... }: {
  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZLAWYLkwEtjlj2e65MwoDOLWUKJBBrjeDf4K0CcuIz alex800121@DaddyAlexAsus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxDNBfYv0w8MLJOLK2nn2kmEpH20G8Y0Mauw9GMHvda alex800121@DaddyAlexAsus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf9DW0O5gkq0ephXxUl7SXgb6TMkAA7RgB9NIl4oKNi alex800121@nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEydwYcKvthPPxPt4P7YkzUgzHahKk/gAMUv7py/jeCN alex800121@acer-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9ecjWEa+jhCOrW4+RkxY0sW7AtsCmTNvdMbdbV/WjG alex800121@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/FOfzUF0nSno+780hSUGX1bDPqmfZpEUG0f/imEl3r alex800121@alexrpi4dorm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnSnbIgHGRRSOQk1TtldRie2Hr9IPhsdX4eAskx1/jM alex800121@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICid1/VEdjJct9RWaL4Hz+igBnu185ySy8kuAxVHZGyN alex800121@m1-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60v2orfSvgFBj2pAPdRTJHRWvHFlICIkUzKEsW4Erc root@asus-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxXK6xHqmWN/gumrcwzaSMk5AOeni/NGXnf2dul1Sax root@acer-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaSD3qsWtMBdadX2256X+2xBl4O3//d/vGUKBxgCTyR root@acer-tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICF22WQW3bhm7MpPR9Ye3SFDudNJ6XdXgEqSIrE7Cv33 root@alexrpi4tp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYMmkDdjmPFYFSPLLWWwoRD6cChs/zFozaHWfiaDsAA root@alexrpi4dorm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFte0h3WjujSOGEUOiD/ruFXMatUobyFJmmpD0iXD8Jy root@m1-nixos"
  ];
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "acer-tp";
      sshUser = "alex800121";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      maxJobs = 4;
    }
    {
      hostName = "acer-nixos";
      sshUser = "alex800121";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      maxJobs = 4;
    }
    {
      hostName = "alexrpi4tp";
      sshUser = "alex800121";
      systems = [ "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
      maxJobs = 2;
    }
    {
      hostName = "alexrpi4dorm";
      sshUser = "alex800121";
      systems = [ "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
      maxJobs = 1;
    }
  ];
}
