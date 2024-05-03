{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  config = {
    services.startx = {
      enable = lib.mkForce config.autoLogin;
      user = config.primaryUser.name;
    };
    services.xserver = {
      dpi = config.dpi;
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xautolock = lib.mkIf config.autoLock.enable {
        enable = true;
        time = config.autoLock.time;
        extraOptions = [ "-detectsleep" ];
        notifier = ''${pkgs.libnotify}/bin/notify-send "Блокировка через 10 секунд"'';
        locker = "/run/wrappers/bin/physlock";
        enableNotifier = true;
      };
      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.tapping = true;
      };
      inputClassSections = [
        ''
          Identifier     "TrackPoint configuration"
          MatchProduct   "TrackPoint"
          Option         "AccelSpeed" "0.6"
        ''
      ];
    };
    environment = {
      etc = {
        "icewm" = {
          source = ../icewm;
        };
      };
    };
  };
}
