{ config, ... }: {
  security.polkit.enable = true;
  systemd.services.dockerd.environment = { };
  systemd.services.docker = { serviceConfig = { LimitNOFILE = 65536; }; };
  programs.extra-container.enable = true;
  virtualisation = {
    cri-o.enable = true;
    kvmgt.enable = !config.minimalInstallation;
    lxc.enable = false;
    lxc.lxcfs.enable = false;
    lxd.enable = false;
    waydroid.enable = false;
    docker = {
      enable = !config.minimalInstallation;
      autoPrune.enable = true;
    };
    virtualbox.guest = {
      enable = false;
      x11 = false;
    };
    virtualbox.host = {
      enable = !config.minimalInstallation;
      headless = false;
      enableExtensionPack = true;
      enableHardening = false;
    };
    libvirtd.enable = !config.minimalInstallation;
  };
  users = let user = config.primaryUser.name;
  in {
    groups = {
      docker.members = [ user ];
      libvirtd.members = [ user ];
      lxd.members = [ user ];
      vboxusers.members = [ user ];
    };
  };
}
