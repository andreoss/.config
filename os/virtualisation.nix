{ self, ... }:
let user = self.config.primaryUser.name;
in {
  security.polkit.enable = true;
  virtualisation = {
    kvmgt.enable = true;
    lxc.enable = false;
    lxc.lxcfs.enable = false;
    lxd.enable = false;
    waydroid.enable = false;
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    virtualbox.guest = {
      enable = false;
      x11 = false;
    };
    virtualbox.host = {
      enable = false;
      headless = false;
      enableExtensionPack = false;
      enableHardening = false;
    };
    libvirtd.enable = true;
  };
  users.extraGroups.docker.members = [ user ];
  users.extraGroups.libvirtd.members = [ user ];
  users.extraGroups.lxd.members = [ user ];
  users.extraGroups.vboxusers.members = [ user ];
}
