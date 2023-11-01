{ lib, pkgs, config, ... }: {
  system = { copySystemConfiguration = false; };
  services = {
    getty.extraArgs = [ "--nohostname" "--noissue" "--noclear" "--nohints" ];
    cron.systemCronJobs = [ "0 2 * * * root fstrim /" ];
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 1;
      freeSwapThreshold = 5;
      extraArgs =
        [ "-g" "--avoid '^(X|brave|java|emacs)$'" "--prefer '^(firefox)$'" ];
    };
    udisks2.enable = true;
    snapper = {
      configs = {
        home = {
          SUBVOLUME = "${config.ao.primaryUser.home}";
          ALLOW_USERS = [ "${config.ao.primaryUser.name}" ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
        };
      };
    };
  };
  systemd = {
    oomd = {
      enable = true;
      enableUserServices = true;
      extraConfig = { DefaultMemoryPressureDurationSec = "20s"; };
    };
  };
  environment.etc."version".text = builtins.readFile
    (pkgs.runCommand "version" {
      nativeBuildInputs = [ pkgs.coreutils pkgs.util-linux ];
    } ''test -d ${../.} && uuidgen > "$out"'');
  environment.etc."packages".text = builtins.toJSON
    (map (x: { "${x.name}" = x.meta or { }; })
      config.environment.systemPackages);
  services.rsyslogd.enable = true;
  services.journald.console = "/dev/tty2";
  services.journald.extraConfig = "Storage=volatile";
  system.activationScripts = {
    restart-journald.text = let path = lib.strings.makeBinPath [ pkgs.systemd ];
    in "${path}/systemctl restart systemd-journald";
  };
}
