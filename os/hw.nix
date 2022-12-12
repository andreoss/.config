{ pkgs, lib, config, self, ... }: {
  hardware.opengl.enable = true;
  hardware.openrazer = {
    enable = false;
    users = [ self.config.primaryUser.name ];
  };
  services.haveged.enable = true;
  programs.light.enable = true;
  hardware.acpilight.enable = true;
  services.acpid.enable = true;
  services.acpid.acEventCommands = ''
    case "$1" in
         ac*0)
           ${pkgs.acpilight}/bin/xbacklight -set 80
          ;;
         ac*1)
           ${pkgs.acpilight}/bin/xbacklight -set 100
          ;;
    esac
  '';
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.powerUpCommands = "${pkgs.acpilight}/bin/xbacklight -set 100";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
