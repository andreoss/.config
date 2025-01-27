{
  pkgs,
  lib,
  config,
  specialArgs,
  ...
}:
{
  hardware = {
    graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault false;
    };
  };
  services.xserver.videoDrivers = [ ];
  services.kmonad = {
    enable = true;
    keyboards = {
      "laptop" = {
        name = "laptop";
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = builtins.readFile ../kbd;
        defcfg = {
          enable = true;
        };
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [
      lm_sensors
      acpi
    ];
  };
  nixpkgs.system = "x86_64-linux";

  services.haveged.enable = true;
  programs.light.enable = true;
  programs.adb.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];
  programs.kbdlight.enable = true;
  hardware.acpilight.enable = true;
  services.systembus-notify.enable = true;
  services.acpid = {
    enable = true;
    logEvents = true;
    acEventCommands = ''
      case "$1" in
           ac*0)
             ${pkgs.acpilight}/bin/xbacklight -set 80
            ;;
           ac*1)
             ${pkgs.acpilight}/bin/xbacklight -set 100
            ;;
      esac
    '';
  };
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.powerUpCommands = "${pkgs.acpilight}/bin/xbacklight -set 100";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
