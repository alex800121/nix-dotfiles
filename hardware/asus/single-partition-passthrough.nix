{ pkgs, ... }: {
  systemd.services.single-partition-passthrough = {
    wantedBy = [ "multi-user.target" ];
    description = "software RAID for single partition passthrough";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    restartIfChanged = false;
    path = with pkgs; [ util-linux mdadm ];
    script = builtins.readFile ./start-software-raid.sh;
  };
}
