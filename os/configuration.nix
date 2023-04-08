{ lib, config, pkgs, self, ... }: {
  system = {
    copySystemConfiguration = false;
    autoUpgrade = {
      enable = false; # does not work with git-crypt
      allowReboot = false;
      dates = "01:00";
      randomizedDelaySec = "10min";
      flake = "github:andreoss/.config";
    };
  };
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
          subvolume = "${config.ao.primaryUser.home}";
          extraConfig = ''
            ALLOW_USERS="${config.ao.primaryUser.name}"
            TIMELINE_CREATE=yes
            TIMELINE_CLEANUP=yes
          '';
        };
      };
    };
  };
  environment.etc."packages".text = builtins.toJSON
    (map (x: { "${x.name}" = x.meta or { }; })
      config.environment.systemPackages);
  systemd.oomd.enable = true;
}
