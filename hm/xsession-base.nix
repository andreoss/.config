{ config, pkgs, lib, inputs, ... }:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
in {
  config = {
    programs.feh.enable = true;
    programs.rofi = {
      enable = true;
      cycle = true;
      terminal = "urxvt";
      theme = "gruvbox-light-soft";
    };
    services.sxhkd = {
      enable = true;
      keybindings = {
        "alt + BackSpace" = "rofi -show-icons -show combi";
        "ctrl + alt + slash" = "rofi -show-icons -show filebrowser";
        "alt + slash" =
          "${inputs.dmenu.packages.x86_64-linux.dmenu}/bin/dmenu_run";
      };
    };
    home.activation.sxhkdUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.procps}/bin/pgrep sxhkd && ${pkgs.procps}/bin/pkill -USR1 sxhkd
    '';
    services.dunst.enable = true;
    services.dunst.settings = with palette; {
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
        background = white3;
        foreground = gray3;
        timeout = 10;
      };
      urgency_normal = {
        background = white4;
        foreground = black1;
        timeout = 20;
      };
      urgency_critical = {
        background = red3;
        foreground = black1;
        timeout = 0;
      };
    };
    fonts.fontconfig.enable = true;
    gtk = {
      font.package = pkgs.terminus_font_ttf;
      font.name = "${font} 9";
      enable = true;
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
      enable = config.ao.primaryUser.graphics;
      style.package = pkgs.adwaita-qt;
    };
    home.packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts
      paratype-pt-mono
      uw-ttyp0
      terminus_font_ttf
      terminus_font
      unifont
      sudo-font
      comic-mono
      _3270font
      wmname
      xclip
      xorg.xkill
      xorg.xdpyinfo
      xorg.xwd
      xorg.xhost
      xpra
      wmctrl
      rox-filer
      xdotool
    ];
    systemd.user.services.fehbg = {
      Unit = {
        Description = "fehbg";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${../wp/1.jpeg}";
        Restart = "never";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
