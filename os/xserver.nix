{ lib, config, pkgs, self, ... }:
let wallpaper = ./../wp/1.jpeg;
in {
  config = {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
    };
    services.startx = {
      enable = true;
      user = if (!config.isLivecd) then config.ao.primaryUser.name else "nixos";
    };
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xautolock = {
        enable = true;
        time = 10;
        extraOptions = [ "-detectsleep" ];
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
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
      enableDefaultFonts = false;
      enableGhostscriptFonts = false;
      fonts = with pkgs; [
        corefonts
        fixedsys-excelsior
        terminus_font
        terminus_font_ttf
        ucs-fonts
        uw-ttyp0
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
        };
      };
    };
    environment = { etc = { "icewm" = { source = ../icewm; }; }; };
  };
}
