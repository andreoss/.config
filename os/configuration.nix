{ lib, config, pkgs, self, ... }: {
  system = { copySystemConfiguration = false; };
  services = {
    getty.extraArgs = [ "--nohostname" "--noissue" "--noclear" "--nohints" ];
    cron.systemCronJobs = [ "0 2 * * * root fstrim /" ];
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 1;
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
  environment.etc."packages".text = builtins.toJSON
    (map (x: { "${x.name}" = x.meta or { }; })
      config.environment.systemPackages);
  systemd.oomd.enable = true;
}
