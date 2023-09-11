{ self, config, ... }:
let user = config.ao.primaryUser.name;
in {
  security.polkit.enable = true;
  programs.extra-container.enable = true;
  virtualisation = {
    cri-o.enable = true;
    kvmgt.enable = !config.mini;
    lxc.enable = false;
    lxc.lxcfs.enable = false;
    lxd.enable = false;
    waydroid.enable = false;
    docker = {
      enable = !config.mini;
      autoPrune.enable = true;
    };
    virtualbox.guest = {
      enable = false;
      x11 = false;
    };
    virtualbox.host = {
      enable = false;
      headless = false;
      enableExtensionPack = true;
      enableHardening = false;
    };
    libvirtd.enable = !config.mini;
  };
  users.groups.docker.members = [ user ];
  users.groups.libvirtd.members = [ user ];
  users.groups.lxd.members = [ user ];
  users.groups.vboxusers.members = [ user ];
}
