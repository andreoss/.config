{
  lib,
  pkgs,
  config,
  ...
}:
{
  system = {
    copySystemConfiguration = false;
  };
  services = {
    getty.extraArgs = [
      "--nohostname"
      "--noissue"
      "--noclear"
      "--nohints"
    ];
    cron.systemCronJobs = [ "0 2 * * * root fstrim /" ];
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 1;
      freeSwapThreshold = 5;
      extraArgs = [
        "-g"
        "--avoid '^(X|brave|java|emacs)$'"
        "--prefer '^(firefox)$'"
      ];
    };
    udisks2.enable = true;
    snapper = lib.mkIf (!config.minimalInstallation) {
      configs = {
        home = {
          SUBVOLUME = "${config.primaryUser.home}";
          ALLOW_USERS = [ "${config.primaryUser.name}" ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
        };
      };
    };
  };
  systemd = {
    oomd = {
      enable = true;
      extraConfig = {
        DefaultMemoryPressureDurationSec = "20s";
      };
    };
  };
  environment.etc."nixos/version".text = config.system.nixos.label;
  environment.etc."nixos/date".text = builtins.readFile (
    pkgs.runCommand "version"
      {
        nativeBuildInputs = [
          pkgs.coreutils
          pkgs.util-linux
        ];
      }
      ''
        cd ${../.}
        date --iso-8601=ns      >> $out
      ''
  );
  environment.etc."packages".text = builtins.toJSON (
    map (x: { "${x.name}" = x.meta or { }; }) config.environment.systemPackages
  );
  services.rsyslogd.enable = true;
  services.journald.extraConfig = "Storage=volatile";
}
