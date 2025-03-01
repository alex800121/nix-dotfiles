{ config, userConfig, lib, ... }: {

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  boot.initrd.network = {
    ssh = {
      enable = true;
      # hostKeys = [ /etc/secrets/initrd_ssh_host_ed25519_key ];
      hostKeys = [];
      ignoreEmptyHostKeys = true;
      port = 2222;
    };
    ssh.authorizedKeys = config.users.users."${userConfig.userName}".openssh.authorizedKeys.keys;
  };

  boot.initrd.secrets = {
    "/etc/secrets/initrd_ssh_host_ed25519_key" = ../secrets/initrd_ssh_host_ed25519_key-${userConfig.hostName};
  };
  boot.initrd.systemd.services.sshd.serviceConfig.LoadCredentialEncrypted = ''
    initrd.ssh.host.key:/etc/secrets/initrd_ssh_host_ed25519_key
  '';
  boot.initrd.systemd.services.sshd.preStart = ''
    mkdir -p /etc/ssh
    cp /run/credentials/sshd.service/initrd.ssh.host.key /etc/ssh/ssh_host_ed25519_key
    chmod 0600 /etc/ssh/ssh_host_ed25519_key
  '';
  # boot.initrd.network.ssh.extraConfig = ''
  #   HostKey /etc/ssh/ssh_host_ed25519_key
  # '';
}
