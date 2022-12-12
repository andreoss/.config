{ self, config, ... }:
let user = config.ao.primaryUser.name;
in {
  security.polkit.enable = true;
  virtualisation = {
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
      enable = !config.mini;
      headless = false;
      enableExtensionPack = false;
      enableHardening = false;
    };
    libvirtd.enable = !config.mini;
  };
  users.extraGroups.docker.members = [ user ];
  users.extraGroups.libvirtd.members = [ user ];
  users.extraGroups.lxd.members = [ user ];
  users.extraGroups.vboxusers.members = [ user ];
}
