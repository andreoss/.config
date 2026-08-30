{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    systemd.user.services = lib.mkIf config.xsession.enable {
      wpa = {
        Unit = {
          Description = "wpa";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10s";
          ExecStart = "${pkgs.wpa_supplicant_gui}/bin/wpa_gui -t";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
      fehbg = {
        Unit = {
          Description = "fehbg";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 5s";
          ExecStart = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${config.backgroundImage}";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
