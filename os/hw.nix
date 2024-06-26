{
  pkgs,
  lib,
  config,
  specialArgs,
  ...
}:
{

  imports = [ ./kmonad.nix ];
  services.kmonad = {
    enable = true;
    configfile = ./../kbd;
    package = specialArgs.inputs.kmonad.packages.x86_64-linux.kmonad;
    devices = [ ];
  };
  environment = {
    systemPackages = with pkgs; [
      lm_sensors
      acpi
    ];
  };
  hardware.opengl.enable = true;
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
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.powerUpCommands = "${pkgs.acpilight}/bin/xbacklight -set 100";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
