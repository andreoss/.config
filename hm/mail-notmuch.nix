{
  config,
  pkgs,
  lib,
  ...
}:
let
  x = false;
in
{
  config = lib.mkIf (builtins.elem "email" config.features) {
    home.file.".config/davmail-base.properties" = lib.attrsets.optionalAttrs (x) {
      text = ''
        davmail.server=true
        davmail.url=https://outlook.office365.com/EWS/Exchange.asmx
        davmail.mode=O365Interactive
        davmail.caldavPort=1080
        davmail.imapPort=1143
        davmail.ldapPort=1389
        davmail.popPort=1110
        davmail.smtpPort=1025
        davmail.enableProxy=true
        davmail.useSystemProxies=true
        davmail.ssl.nosecurecaldav=true
        davmail.ssl.nosecureimap=true
        davmail.ssl.nosecureldap=true
        davmail.ssl.nosecuresmtp=true
        log4j.rootLogger=WARN
      '';
    };
    programs = lib.attrsets.optionalAttrs (x) {
      notmuch = {
        enable = x;
        new = {
          tags = [ "new" ];
        };
        hooks = {
          postInsert = "";
          preNew = "mbsync --all || true";
          postNew = ''
            NEW_MAIL=$(notmuch count tag:new)
            if [ "$NEW_MAIL" -gt 0 ]
            then
               ${pkgs.libnotify}/bin/notify-send "✉ + $(notmuch count tag:new) / $(notmuch count tag:unread)"
               notmuch search tag:new | awk '{print $1}' | while read id;
               do
                   m=$(notmuch show --format-version=1 --format=json "$id"  | jq '.[].[].[] | .headers' | json2yaml)
                   nid=$(dunstify -p "$m")
                   notmuch tag +notified +"nid:$nid" -- $id
               done
               notmuch tag +inbox +unread -new -- tag:new
            fi
          '';
        };
      };
    };
    systemd = lib.attrsets.optionalAttrs (x) {
      user.services.mbsync =
        let
          path = lib.strings.makeBinPath [
            pkgs.isync
            pkgs.pass
            pkgs.gawk
            pkgs.coreutils
            pkgs.gnugrep
          ];
        in
        {
          Service = {
            Environment = [ "PATH=${path}" ];
            ExecStartPre = "systemctl is-active sys-devices-virtual-net-tun0.device";
          };
        };
      user.services.notmuch =
        let
          path = lib.strings.makeBinPath [
            pkgs.isync
            pkgs.pass
            pkgs.gawk
            pkgs.coreutils
            pkgs.gnugrep
          ];
        in
        {
          Unit = {
            Requires = [ "davmail.service" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            ExecStart = "${pkgs.notmuch}/bin/notmuch new";
            Environment = [ "PATH=${path}" ];
          };
        };
      user.timers.notmuch = {
        Install = {
          WantedBy = [ "timers.target" ];
        };
        Timer = {
          OnBootSec = "10m";
          OnCalendar = "*:0/5";
        };
      };
      user.services.davmail =
        let
          write-properties = pkgs.writeShellScript "write-properties" ''
            cat "$HOME"/.config/davmail-base.properties > "$HOME"/.config/davmail.properties
          '';
          run-davmail = pkgs.writeShellScript "run-davmail" ''
            exec davmail "$HOME"/.config/davmail.properties
          '';
        in
        {
          Unit = {
            Description = "Davmail";
            PartOf = [ "graphical-session.target" ];
          };
          Service =
            let
              path = lib.strings.makeBinPath [
                pkgs.coreutils
                pkgs.gnugrep
                (pkgs.davmail.override { jre = pkgs.openjdk17; })
              ];
            in
            {
              ExecStartPre = "${write-properties}";
              ExecStart = "${run-davmail}";
              Environment = [ "PATH=${path}" ];
            };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
    };
  };
}
