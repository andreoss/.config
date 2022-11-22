{ config, pkgs, lib, stdenv, self, ... }: {
  config = lib.attrsets.optionalAttrs (self.config.primaryUser.mail) {
    accounts.email = {
      maildirBasePath = "${config.home.homeDirectory}/Maildir";
    };
    accounts.email.accounts = if (lib.pathExists ../secrets/mail.nix) then
      (import ../secrets/mail.nix)
    else
      { };
    programs.mbsync.enable = lib.pathExists ../secrets/mail.nix;
    programs.msmtp.enable = lib.pathExists ../secrets/mail.nix;
    programs.notmuch = {
      enable = lib.pathExists ../secrets/mail.nix;
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
    services.mbsync.enable = lib.pathExists ../secrets/mail.nix;
    systemd.user.services.notmuch = {
      Unit = { Requires = [ "davmail.service" ]; };
      Install = { WantedBy = [ "default.target" ]; };
      Service = {
        ExecStart = "${pkgs.notmuch}/bin/notmuch new";
        Environment = [ "PATH=${pkgs.isync}/bin:${pkgs.pass}/bin:$PATH" ];
      };
    };
    systemd.user.timers.notmuch = {
      Install = { WantedBy = [ "timers.target" ]; };
      Timer = {
        OnBootSec = "10m"; # first run 10min after boot up
        OnCalendar = "*:0/5";
      };
    };
    systemd.user.services.davmail = {
      Unit = {
        Description = "Davmail";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.davmail}/bin/davmail";
        Environment = [ "PATH=${pkgs.coreutils}/bin:$PATH" ];
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
    home.activation.davmailHeadless =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        touch "$HOME"/.davmail.properties
        ${pkgs.perl536}/bin/perl -i -lpE 'BEGIN {my $f=0;} m/ davmail[.]server = /xgsm && s/ (?<=\=) .* $ /true/xgsm && $f++; END { if (!$f) { print "davmail.server=true " } }' "$HOME"/.davmail.properties
        ${pkgs.systemd}/bin/systemctl --user restart davmail.service
      '';
  };
}
