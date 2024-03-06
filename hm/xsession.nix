{ config, pkgs, lib, stdenv, inputs, ... }:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
in {
  config = {
    xsession = {
      enable = true;
      scriptPath = ".xinitrc";
      windowManager.command =
        let path = lib.strings.makeBinPath [ pkgs.icewm pkgs.dmenu ];
        in ''
          PATH=$PATH:${path}
          PATH=$PATH:$HOME/.local/bin
          export PATH
          if grep closed /proc/acpi/button/lid*/LID*/state >/dev/null
          then
              autorandr docked
          fi
          echo "Xft.dpi: 120" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
          LC_MESSAGES="$LC_NAME" icewm-session
          while :
          do
                CMD=$(dmenu </dev/null)
                if [ "$CMD" = "exit" ]
                then
                  exit
                else
                  $CMD
                fi
          done
          wait
        '';
    };
    services.gammastep = {
      enable = config.xsession.enable;
      longitude = -55.0;
      latitude = -27.0;
      temperature = {
        day = 8000;
        night = 4500;
      };
      tray = true;
    };
    services.udiskie = {
      enable = config.xsession.enable;
      automount = false;
    };
    services.cbatticon.enable = config.xsession.enable;
    services.keynav.enable = config.xsession.enable;
    programs.autorandr = {
      enable = config.xsession.enable;
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
      enable = config.xsession.enable;
      keybindings = {
        "XF86MonBrightnessDown" = "xbacklight -dec 10";
        "XF86MonBrightnessUp" = "xbacklight -inc 10";
        "XF86Display" = ''
          if systemctl --user is-active gammastep.service;then systemctl --user stop gammastep.service ; else systemctl --user start gammastep.service; fi
                    inactive'';
      };
    };
    systemd.user.services = lib.mkIf config.xsession.enable {
      keynav.Service.Environment =
        [ "PATH=${pkgs.xdotool}/bin:${pkgs.wmctrl}/bin:$PATH" ];
      conky = let
        path = lib.strings.makeBinPath [
          pkgs.coreutils
          pkgs.notmuch
          pkgs.util-linux
          pkgs.gnused
          pkgs.conky
        ];
      in {
        Unit = {
          Description = "Conky";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart =
            "${pkgs.conky}/bin/conky --daemonize --config=${../conkyrc}";
          Environment = [ "PATH=${path}" ];
          Type = "forking";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
      volumeicon = {
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
  };
}
