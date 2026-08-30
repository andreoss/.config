{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  config = {
    home.activation = lib.mkIf config.services.sxhkd.enable {
      sxhkdUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.procps}/bin/pgrep sxhkd && ${pkgs.procps}/bin/pkill -USR1 sxhkd
      '';
    };
    services.sxhkd = {
      enable = config.xsession.enable;
      keybindings = {
        "alt + slash" = "dbus-launch rofi -show-icons -show combi";
        "ctrl + alt + slash" = "dbus-launch rofi -show-icons -show filebrowser";
        "alt + BackSpace" = "${inputs.dmenu.packages.x86_64-linux.dmenu}/bin/dmenu_run";
      };
    };
  };
}
