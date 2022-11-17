{ lib, config, pkgs, self, ... }:
let
  wallpaper = ./../wp/1.jpeg;
in {
  services.xserver = {
    enable = true;
    xautolock = {
      enable = true;
      time = 10;
      extraOptions = [  "-detectsleep" ];
      notifier = "${pkgs.libnotify}/bin/notify-send \"Locking in 10 seconds\"";
      locker = "/run/wrappers/bin/physlock";
      enableNotifier = true;
    };
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
      touchpad.tapping = true;
    };
    displayManager = {
      autoLogin.enable = self.config.primaryUser.autoLogin;
      autoLogin.user = self.config.primaryUser.name;
      lightdm.enable = true;
      lightdm.background = wallpaper;
      lightdm.greeters.enso.blur = true;
      lightdm.greeters.enso.enable = true;
      lightdm.autoLogin.timeout = 5;
    };
    displayManager.defaultSession = "none+icewm";
    displayManager.sessionPackages = with pkgs; [];
    displayManager.sessionCommands = ''
         {
            sleep 1
            ${pkgs.feh}/bin/feh --no-fehbg --bg-center ${wallpaper}
         } &
    '';
    windowManager = {
      icewm.enable = true;
    };
    inputClassSections = [
      ''
      Identifier     "TrackPoint configuration"
      MatchProduct   "TrackPoint"
      Option         "AccelSpeed" "0.6"
    ''
    ];
  };
  fonts = {
    enableDefaultFonts = false;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ucs-fonts
      gyre-fonts
      terminus_font
      terminus_font_ttf
    ];
    fontconfig = {
      hinting.autohint = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        monospace = [ "Terminus" ];
        sansSerif = [ "Go" ];
        serif = [ "Go Medium" ];
      };
    };
  };
}
