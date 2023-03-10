{ config, pkgs, lib, stdenv, inputs, ... }:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
in {
  config = {
    xsession = {
      enable = true;
      scriptPath = ".xinitrc";
      windowManager.command = ''
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
      temperature = {
        day = 8000;
        night = 2500;
      };
    };
    services.udiskie.enable = true;
    services.cbatticon.enable = config.ao.primaryUser.graphics;
    services.keynav.enable = config.ao.primaryUser.graphics;
    systemd.user.services.keynav.Service.Environment =
      [ "PATH=${pkgs.xdotool}/bin:${pkgs.wmctrl}/bin:$PATH" ];
    programs.autorandr = {
      enable = config.ao.primaryUser.graphics;
      hooks = {
        postswitch = {
          icewm-restart = "${pkgs.icewm}/bin/icesh restart";
          dunst-restart = "systemctl --user restart dunst.service";
          background = "systemctl --user restart fehbg.service";
          fix-dpi = ''
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
      enable = true;
      keybindings = {
        "alt + slash" = "rofi -show-icons -show combi";
        "ctrl + alt + slash" = "rofi -show-icons -show filebrowser";
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioStop" = "playerctl stop";
        "XF86AudioPrev" = "playerctl previous";
        "XF86AudioNext" = "playerctl next";
        "XF86MonBrightnessDown" = "xbacklight -dec 10";
        "XF86MonBrightnessUp" = "xbacklight -inc 10";
        "XF86Display" = ''
          if systemctl --user is-active gammastep.service;then systemctl --user stop gammastep.service ; else systemctl --user start gammastep.service; fi
                    inactive'';
        "XF86Tools" = "playerctl previous";
        "XF86LaunchA" = "playerctl stop";
        "XF86Explorer" = "playerctl next";
        "XF86Search" = "playerctl play-pause";
        "XF86AudioMute" = ''
          ${pkgs.pamixer}/bin/pamixer --toggle-mute && ${pkgs.libnotify}/bin/notify-send --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioMicMute" = ''
          ${pkgs.pamixer}/bin/pamixer --toggle-mute --default-source && ${pkgs.libnotify}/bin/notify-send --expire-time=3000 --urgency=critical --replace-id=16 "🎤 $(${pkgs.pamixer}/bin/pamixer --get-volume-human --default-source)"'';
        "XF86AudioLowerVolume" = ''
          ${pkgs.pamixer}/bin/pamixer --decrease 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioRaiseVolume" = ''
          ${pkgs.pamixer}/bin/pamixer --increase 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
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
        Restart = "always";
        RestartSec = "3";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
