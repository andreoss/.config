{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    services.sxhkd = lib.mkIf config.services.playerctld.enable {
      keybindings = {
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioStop" = "playerctl stop";
        "XF86AudioPrev" = "playerctl previous";
        "XF86AudioNext" = "playerctl next";
        "XF86Tools" = "playerctl previous";
        "XF86LaunchA" = "playerctl stop";
        "XF86Explorer" = "playerctl next";
        "XF86Search" = "playerctl play-pause";
        "XF86AudioMute" =
          ''${pkgs.pamixer}/bin/pamixer --toggle-mute && ${pkgs.libnotify}/bin/notify-send --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioMicMute" =
          ''${pkgs.pamixer}/bin/pamixer --toggle-mute --default-source && ${pkgs.libnotify}/bin/notify-send --expire-time=3000 --urgency=critical --replace-id=16 "🎤 $(${pkgs.pamixer}/bin/pamixer --get-volume-human --default-source)"'';
        "XF86AudioLowerVolume" =
          ''${pkgs.pamixer}/bin/pamixer --decrease 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioRaiseVolume" =
          ''${pkgs.pamixer}/bin/pamixer --increase 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
      };
    };
  };
}
