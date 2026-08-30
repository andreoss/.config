{
  config,
  pkgs,
  lib,
  stdenv,
  inputs,
  ...
}:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
in
{
  config = {
    xsession = {
      enable = true;
      scriptPath = ".xinitrc";
      windowManager.command =
        let
          path = lib.strings.makeBinPath [
            pkgs.icewm
            pkgs.dmenu
            pkgs.xdgmenumaker
          ];
        in
        ''
          PATH=$PATH:${path}
          PATH=$PATH:$HOME/.local/bin
          export PATH
          if grep closed /proc/acpi/button/lid*/LID*/state >/dev/null
          then
              autorandr docked
          else
              autorandr mobile
          fi
          echo "Xft.dpi: ${builtins.toString config.dpi}" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
          mkdir --parent ~/.config/icewm
          rm --force ~/.config/icewm/menu
          xdgmenumaker -i -f icewm > ~/.config/icewm/menu
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
                DPI=${builtins.toString (2 * config.dpi)}
                ;;
                mobile)
                DPI=${builtins.toString config.dpi}
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
  };
}
