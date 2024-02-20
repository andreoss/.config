{ pkgs, lib, config, specialArgs, ... }: {

  imports = [ ./kmonad.nix ];
  services.kmonad = {
    enable = true;
    configfile = ./../kbd;
    package = specialArgs.inputs.kmonad.packages.x86_64-linux.kmonad;
    devices = [ ];
  };
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  services.haveged.enable = true;
  programs.light.enable = true;
  programs.adb.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];
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
  services.throttled.enable = true;
  services.upower.enable = true;
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.powerUpCommands = "${pkgs.acpilight}/bin/xbacklight -set 100";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
