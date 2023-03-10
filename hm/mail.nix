{ config, pkgs, lib, stdenv, self, ... }:
let
  e = config.ao.primaryUser.mail;
  x = lib.pathExists ../secrets/mail.nix;
in {
  config.accounts = lib.attrsets.optionalAttrs (e) {
    email = { maildirBasePath = "${config.home.homeDirectory}/Maildir"; };
    email.accounts = if (x) then (import ../secrets/mail.nix) else { };
  };
  config.programs = lib.attrsets.optionalAttrs (e) {
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
  config.systemd = lib.attrsets.optionalAttrs (e) {
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
    user.services.davmail = {
      Unit = {
        Description = "Davmail";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.davmail}/bin/davmail $HOME/.davmail.properties";
        Environment = [ "PATH=${pkgs.coreutils}/bin:$PATH" ];
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
  config.services = lib.attrsets.optionalAttrs (e) { mbsync.enable = x; };
  config.home = lib.attrsets.optionalAttrs (e) {
    activation.davmailHeadless = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
      ${pkgs.systemd}/bin/systemctl --user restart davmail.service
    '';
  };
}
