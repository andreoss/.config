{ config, pkgs, lib, inputs, ... }:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
in {
  options = { };
  config = {
    home.pointerCursor = {
      package = pkgs.openzone-cursors;
      name = "OpenZone_White";
      x11.enable = config.xsession.enable;
      x11.defaultCursor = "left_ptr";
    };
    home.activation = lib.mkIf config.services.sxhkd.enable {
      sxhkdUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.procps}/bin/pgrep sxhkd && ${pkgs.procps}/bin/pkill -USR1 sxhkd
      '';
    };
    programs.feh.enable = config.xsession.enable;
    programs.rofi = {
      enable = config.xsession.enable;
      cycle = true;
      terminal = "urxvt";
      theme = "gruvbox-light-soft";
    };
    services.sxhkd = {
      enable = config.xsession.enable;
      keybindings = {
        "alt + BackSpace" = "rofi -show-icons -show combi";
        "ctrl + alt + slash" = "rofi -show-icons -show filebrowser";
        "alt + slash" =
          "${inputs.dmenu.packages.x86_64-linux.dmenu}/bin/dmenu_run";
      };
    };
    services.dunst = {
      enable = config.xsession.enable;
      settings = with palette; {
        global = {
          frame_color = black1;
          separator_color = gray4;
          transparency = 80;
          font = "${font}";
          alignment = "center";
          word_warp = "true";
          line_height = 3;
          geometry = "384x5-30+20";
        };
        urgency_low = {
          background = gray5;
          foreground = black0;
          timeout = 10;
        };
        urgency_normal = {
          background = gray5;
          foreground = black0;
          timeout = 20;
        };
        urgency_critical = {
          background = white3;
          foreground = black1;
          frame_color = red1;
          timeout = 0;
        };
      };
    };
    fonts.fontconfig.enable = config.xsession.enable;
    gtk = {
      enable = config.xsession.enable;
      font.package = pkgs.terminus_font_ttf;
      font.name = "${font} 9";
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
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
      enable = config.xsession.enable;
      style.package = pkgs.adwaita-qt;
    };
    home.packages = lib.optionals config.xsession.enable (with pkgs; [
      luculent
      cherry
      noto-fonts-emoji
      noto-fonts
      paratype-pt-mono
      uw-ttyp0
      terminus_font_ttf
      terminus_font
      uni-vga
      junicode
      glasstty-ttf
      fontpreview
      junction-font
      sudo-font
      comic-mono
      _3270font
      wmname
      xclip
      dosemu_fonts
      last-resort
      recursive
      xorg.xkill
      xorg.xdpyinfo
      xorg.xwd
      xorg.xhost
      xpra
      wmctrl
      rox-filer
      cozette
      xdotool
    ]);
    home.sessionVariables = lib.mkIf config.xsession.enable {
      XDG_SESSION_PATH = "";
      XDG_SESSION_DESKTOP = "";
      XDG_SESSION_TYPE = "";
      XDG_SESSION_CLASS = "";
      XDG_SESSION_ID = "";
      XDG_CURRENT_SESSION = "";
      GDMSESSION = "";
      DESKTOP_SESSION = "";
    };
    systemd.user.services = lib.mkIf config.xsession.enable {
      fehbg = {
        Unit = {
          Description = "fehbg";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart =
            "${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${../wp/1.jpeg}";
          Restart = "never";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
  };
}
