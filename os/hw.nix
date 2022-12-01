{ self, ... }: {
  hardware.opengl.enable = true;
  hardware.openrazer = {
    enable = false;
    users = [ self.config.primaryUser.name ];
  };
  services.haveged.enable = true;
  programs.light.enable = true;
  hardware.acpilight.enable = true;
  services.acpid.enable = true;
}
