{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  config = {
    programs.dconf.enable = true;
    services.startx = {
      enable = lib.mkForce config.autoLogin;
      user = config.primaryUser.name;
    };
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
      touchpad.tapping = true;
    };
    services.xserver = {
      dpi = config.dpi;
      enable = true;
      upscaleDefaultCursor = true;
      exportConfiguration = true;
      excludePackages = [ pkgs.xterm ];
      xautolock = lib.mkIf config.autoLock.enable {
        enable = true;
        time = config.autoLock.time;
        extraOptions = [ ];
        notifier = ''${pkgs.libnotify}/bin/notify-send "Блокировка через 10 секунд"'';
        locker = "${pkgs.alock}/bin/alock";
        enableNotifier = true;
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
