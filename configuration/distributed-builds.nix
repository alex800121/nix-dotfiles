{ ... }: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "acer-tp";
      sshUser = "alex800121";
      systems = ["x86_64-linux" "aarch64-linux"];
      maxJobs = 3;
    }
    {
      hostName = "acer-nixos";
      sshUser = "alex800121";
      systems = ["x86_64-linux" "aarch64-linux"];
      maxJobs = 3;
    }
  ];
}
