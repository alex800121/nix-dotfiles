{ pkgs, userConfig, ... }: { 
  environment.systemPackages = with pkgs; [
    seaweedfs
  ];
  home-manager.users."${userConfig.userName}".programs.bash.bashrcExtra = ''
    complete -C ${pkgs.seaweedfs}/bin/weed weed
  '';
}

