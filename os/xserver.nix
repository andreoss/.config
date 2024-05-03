{ lib, config, pkgs, self, ... }: {
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
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Блокировка через 10 секунд"'';
        locker = "/run/wrappers/bin/physlock";
        enableNotifier = true;
      };
      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.tapping = true;
      };
      inputClassSections = [''
        Identifier     "TrackPoint configuration"
        MatchProduct   "TrackPoint"
        Option         "AccelSpeed" "0.6"
      ''];
    };
    fonts = {
      fontDir = { enable = true; };
      enableDefaultPackages = true;
      enableGhostscriptFonts = true;
      packages = with pkgs; [
        _3270font
        fixedsys-excelsior
        hermit
        julia-mono
        maple-mono
        terminus_font
        terminus_font_ttf
        ucs-fonts
        uw-ttyp0
        spleen
      ];
      fontconfig = {
        hinting.enable = true;
        hinting.autohint = true;
        hinting.style = "full";
        useEmbeddedBitmaps = true;
        defaultFonts = {
          monospace = [ "Terminus" ];
          sansSerif = [ "Terminus" ];
          serif = [ "Terminus" ];
          emoji = [ "Unifont" ];
        };
      };
    };
    environment = { etc = { "icewm" = { source = ../icewm; }; }; };
  };
}
