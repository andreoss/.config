{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    systemd.user.services = lib.mkIf config.xsession.enable {
      keynav.Service.Environment = [ "PATH=${pkgs.xdotool}/bin:${pkgs.wmctrl}/bin:$PATH" ];
      conky =
        let
          path = lib.strings.makeBinPath [
            pkgs.coreutils
            pkgs.notmuch
            pkgs.util-linux
            pkgs.gnused
            pkgs.conky
          ];
        in
        {
          Unit = {
            Description = "Conky";
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.conky}/bin/conky --daemonize --config=${../conkyrc}";
            Environment = [ "PATH=${path}" ];
            Type = "forking";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
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
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
