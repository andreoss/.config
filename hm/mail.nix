{ config, pkgs, lib, stdenv, self, ... }:
let x = lib.pathExists ../secrets/mail.nix;
in {
  config = {
    accounts = lib.attrsets.optionalAttrs (x) {
      email = { maildirBasePath = "${config.home.homeDirectory}/Maildir"; };
      email.accounts = if (x) then (import ../secrets/mail.nix) else { };
    };
    programs = lib.attrsets.optionalAttrs (x) {
      mbsync.enable = x;
      msmtp.enable = x;
      notmuch = {
        enable = x;
        new = { tags = [ "new" ]; };
        hooks = {
          postInsert = "";
          preNew = "mbsync --all || true";
          postNew = ''
            NEW_MAIL=$(notmuch count tag:new)
            if [ "$NEW_MAIL" -gt 0 ]
            then
               ${pkgs.libnotify}/bin/notify-send "✉ + $(notmuch count tag:new) / $(notmuch count tag:unread)"
               notmuch tag +inbox +unread -new -- tag:new
            fi
          '';
        };
      };
    };
    systemd = lib.attrsets.optionalAttrs (x) {
      user.services.notmuch = {
        Unit = { Requires = [ "davmail.service" ]; };
        Install = { WantedBy = [ "default.target" ]; };
        Service = {
          ExecStart = "${pkgs.notmuch}/bin/notmuch new";
          Environment = [ "PATH=${pkgs.isync}/bin:${pkgs.pass}/bin:$PATH" ];
        };
      };
      user.timers.notmuch = {
        Install = { WantedBy = [ "timers.target" ]; };
        Timer = {
          OnBootSec = "10m"; # first run 10min after boot up
          OnCalendar = "*:0/5";
        };
      };
      user.services.davmail = let
        writeProperties = pkgs.writeShellScript "write-properties" ''
          touch "$HOME"/.davmail.properties
          ${pkgs.perl536}/bin/perl -i -lnE '
                 next if m/ davmail [.] (?: server | mode | url ) \s* = /xgsm;
                 s/WARN/INFO/;
                 say;
                 if (eof) {
                    say "davmail.server=true";
                    say "davmail.url=https://outlook.office365.com/EWS/Exchange.asmx";
                    say "davmail.mode=O365Manual";
                 }
          ' "$HOME"/.davmail.properties
        '';
      in {
        Unit = {
          Description = "Davmail";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${writeProperties}";
          ExecStart = "${pkgs.davmail}/bin/davmail $HOME/.davmail.properties";
          Environment = [ "PATH=${pkgs.coreutils}/bin:$PATH" ];
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
    services = lib.attrsets.optionalAttrs (x) { mbsync.enable = x; };
  };
}
