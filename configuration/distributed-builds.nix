{ ... }: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
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
  ];
}
