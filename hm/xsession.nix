{ config, pkgs, lib, stdenv, self, ... }:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
in {
  config = {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
    xsession = {
      enable = true;
      scriptPath = ".xinitrc";
      windowManager.command = ''
        ${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${../wp/1.jpeg} &
        PATH=$PATH:${pkgs.icewm}/bin
        export PATH
        if grep closed /proc/acpi/button/lid*/LID*/state >/dev/null
        then
            autorandr docked
        fi
        icewm-session --nobg &
        wait
      '';
    };
    services.gammastep = {
      enable = config.ao.primaryUser.graphics;
      longitude = -55.0;
      latitude = -27.0;
    };
    services.cbatticon.enable = config.ao.primaryUser.graphics;
    services.keynav.enable = config.ao.primaryUser.graphics;
    services.dunst.enable = config.ao.primaryUser.graphics;
    services.dunst.settings = {
      global = {
        frame_color = palette.black1;
        separator_color = palette.gray4;
      };
      urgency_low = {
        background = palette.white1;
        foreground = palette.gray3;
      };
      urgency_normal = {
        background = palette.white2;
        foreground = palette.black1;
      };
      urgency_critical = {
        background = palette.red1;
        foreground = palette.black1;
      };
      global.font = "${font}";
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
      font.name = "${font} 9";
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
      enable = config.ao.primaryUser.graphics;
      style.package = pkgs.adwaita-qt;
    };
    programs.feh.enable = config.ao.primaryUser.graphics;
    home.keyboard.layout = "us,ru";
    home.keyboard.options = [ "ctrl:nocaps,grp:shifts_toggle" "compose:ralt" ];
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
      enable = config.ao.primaryUser.graphics;
      hooks = {
        postswitch = {
          "icewm-restart" = "${pkgs.icewm}/bin/icesh restart";
          "dunst-restart" = "systemctl --user restart dunst.service";
          "background" =
            "${pkgs.feh}/bin/feh --no-fehbg --bg-center ${../wp/1.jpeg}";
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
    programs.rofi = {
      enable = true;
      cycle = true;
      terminal = "urxvt";
      theme = "gruvbox-light-soft";
    };
    services.sxhkd = {
      enable = config.ao.primaryUser.graphics;
      keybindings = {
        "alt + slash" = "rofi -show-icons -show combi";
        "ctrl + alt + slash" = "rofi -show-icons -show filebrowser";
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioStop" = "playerctl stop";
        "XF86AudioPrev" = "playerctl previous";
        "XF86AudioNext" = "playerctl next";
        "XF86MonBrightnessDown" = "xbacklight -dec 10";
        "XF86MonBrightnessUp" = "xbacklight -inc 10";
        "XF86Display" = "if systemctl --user is-active gammastep.service;then systemctl --user stop gammastep.service ; else systemctl --user start gammastep.service; fi
inactive";
        "XF86Tools" = "urxvt";
        "XF86LaunchA" = "emacs";
        "XF86Explorer" = "urxvt -e mc";
        "XF86Search" = "firefox";
        "XF86AudioMute" = "${pkgs.pamixer}/bin/pamixer --toggle-mute";
        "XF86AudioMicMute" = "${pkgs.pamixer}/bin/pamixer --toggle-mute --default-source";
        "XF86AudioLowerVolume" = "${pkgs.pamixer}/bin/pamixer --decrease 8";
        "XF86AudioRaiseVolume" = "${pkgs.pamixer}/bin/pamixer --increase 8";
      };
    };
    systemd.user.services.conky = {
      Unit = {
        Description = "Conky";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart =
          "${pkgs.conky}/bin/conky --daemonize --config=${../conkyrc}";
        Environment =
          [ "PATH=${pkgs.coreutils}/bin:${pkgs.notmuch}/bin:$PATH" ];
        Type = "forking";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
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
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
    home.activation.sxhkdUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.procps}/bin/pkill -c -USR1 sxhkd
    '';
    home.packages = with pkgs;
      [
        paratype-pt-mono
        uw-ttyp0
        terminus_font_ttf
        terminus_font
        gentium
        unifont
        sudo-font
        dina-font
      ] ++ (lib.optionals (config.ao.primaryUser.graphics) [
        wmname
        xclip
        xorg.xkill
        xorg.xdpyinfo
        rox-filer
        xdotool
      ]);
  };
}
