{ config, pkgs, lib, stdenv, self, ... }:
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  xsession = {
    enable = true;
    scriptPath = ".xsession";
    windowManager.command = ''
       ${pkgs.icewm}/bin/icewm-session &
       ${pkgs.feh}/bin/feh --no-fehbg --bg-center ${../wp/1.jpeg} &
       while :
       do
          sleep 1m
       done
      wait
    '';
  };
  services.gammastep = {
    enable = self.config.primaryUser.graphics;
    longitude = -55.89;
    latitude = -27.36;
  };
  services.cbatticon.enable = self.config.primaryUser.graphics;
  services.keynav.enable = self.config.primaryUser.graphics;
  services.dunst.enable = self.config.primaryUser.graphics;
  services.dunst.settings = {
    global = {
      frame_color = "#121212";
      separator_color = "#434343";
    };
    urgency_low = {
      background = "#585858";
      foreground = "#EAEAEA";
    };
    urgency_normal = {
      background = "#FFFFEA";
      foreground = "#121212";
    };
    urgency_critical = {
      background = "#AA222E";
      foreground = "#959DCB";
    };
    global.font = "Terminus";
    global.alignment = "right";
    global.word_warp = "true";
    global.line_height = 3;
    global.geometry = "384x5-30+20";
    urgency_low.timeout = 5;
    urgency_normal.timeout = 15;
    urgency_critical.timeout = 0;
  };
  fonts.fontconfig.enable = true;
  gtk = {
    font.package = pkgs.terminus_font_ttf;
    font.name = "Terminus 9";
    enable = true;
    iconTheme.name = "Adwaita";
    iconTheme.package = pkgs.gnome.adwaita-icon-theme;
    gtk2.extraConfig = "";
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-fallback-icon-theme = "gnome";
      gtk-button-images = 0;
      gtk-cursor-theme-size = 0;
      gtk-enable-animations = false;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
     gtk3.bookmarks = [
       "file://${config.home.homeDirectory}/Books/"
       "file://${config.home.homeDirectory}/Work/"
       "file://${config.home.homeDirectory}/Finance/"
       "file://${config.home.homeDirectory}/Official/"
     ];
  };
  qt = {
    enable = self.config.primaryUser.graphics;
    platformTheme = "gtk";
  };
  programs.feh.enable = self.config.primaryUser.graphics;
  home.keyboard.layout = "us,ru";
  home.keyboard.options = [ "ctrl:nocaps,grp:shifts_toggle" "compose:ralt" ];
  services.xcape = {
    enable = self.config.primaryUser.graphics;
    mapExpression = {
      "Control_L" = "Escape";
      "Control_R" = "Escape";
    };
  };
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "${../wp/1.jpeg}";
      picture-options = "centered";
    };
    "org/gnome/desktop/sound" = { event-sounds = false; };
    "org/gnome/desktop/input-sources" = {
      xkb-options = config.home.keyboard.options;
      sources = builtins.map (x: "('xkb', '${x}')")
        (lib.strings.splitString "," config.home.keyboard.layout);
    };
  };
  programs.autorandr = {
    enable = self.config.primaryUser.graphics;
    hooks = {
      postswitch = {
        "icewm-restart" = "${pkgs.icewm}/bin/icesh restart";
        "dunst-restart" = "systemctl --user restart dunst.service";
        "background" = ''${pkgs.feh}/bin/feh --no-fehbg --bg-center ${../wp/1.jpeg}'';
        "fix-dpi" = ''
               case "$AUTORANDR_CURRENT_PROFILE" in
                 docked)
                   DPI=192
                   ;;
                 mobile)
                   DPI=96
                   ;;
                 *)
                   echo "Unknown profile: $AUTORANDR_CURRENT_PROFILE"
                   exit 1
               esac
               echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
               systemctl --user restart conky.service
         '';
      };
    };
  };
  services.sxhkd = {
    enable = self.config.primaryUser.graphics;
    keybindings = {
      "alt + slash" = "PATH=$PATH:${pkgs.rofi}/bin rofi -show combi";
    };
  };
  systemd.user.services.conky = {
    Unit = {
      Description = "Conky";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.conky}/bin/conky --daemonize --config=${../conkyrc}";
      Environment = [
        "PATH=${pkgs.coreutils}/bin:${pkgs.notmuch}/bin:$PATH"
      ];
      Type = "forking";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  systemd.user.services.volumeicon = {
    Unit = {
      Description = "Volumeicon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.volumeicon}/bin/volumeicon";
      Environment = [ "PATH=${pkgs.coreutils}/bin:$PATH" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
