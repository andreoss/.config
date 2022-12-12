{ lib, config, pkgs, self, ... }:
let wallpaper = ./../wp/1.jpeg;
in {
  config = {
    services.xserver = {
      enable = true;
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
      displayManager = { startx.enable = true; };
      inputClassSections = [''
        Identifier     "TrackPoint configuration"
        MatchProduct   "TrackPoint"
        Option         "AccelSpeed" "0.6"
      ''];
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
    environment = { etc = { "icewm" = { source = ../icewm; }; }; };
    systemd.services."autovt@tty1".enable = lib.mkForce false;
    systemd.services = {
      startx = {
        enable = true;
        restartIfChanged = true;
        description = "startx";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = if(!config.isLivecd) then config.ao.primaryUser.name else "nixos";
          WorkingDirectory = "~";
          PAMName = "login";
          TTYPath = "/dev/tty1";
          UtmpIdentifier = "tty1";
          UtmpMode = "user";
          UnsetEnvirnment = "TERM";
          #ExecStartPost = "/run/wrappers/bin/physlock";
          ExecStart =
            "${pkgs.xorg.xinit}/bin/startx -- -keeptty -verbose 3 -depth 16";
          StandardInput = "tty";
          StandardOutput = "journal";
          Restart = "always";
        };
      };
    };
  };
}
