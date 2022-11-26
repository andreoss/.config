{ lib, config, pkgs, self, ... }:
let user = self.config.primaryUser.name;
in {
  services.dbus = {
    enable = true;
    packages = [ pkgs.gcr ];
  };
  programs.dconf.enable = true;
  system.copySystemConfiguration = false;
  system.autoUpgrade = {
    enable = false; # does not work with git-crypt
    allowReboot = false;
    dates = "01:00";
    randomizedDelaySec = "10min";
    flake = "github:andreoss/.config";
  };
  services.getty.extraArgs =
    [ "--nohostname" "--noissue" "--noclear" "--nohints" ];
  services.cron.systemCronJobs = [ "0 2 * * * root fstrim /" ];
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 1;
  };
  services.physlock = {
    enable = true;
    allowAnyUser = true;
  };
  environment.etc."packages".text = with lib;
    builtins.concatStringsSep "\n" (builtins.sort builtins.lessThan (lib.unique
      (builtins.map (p: "${p.name}") config.environment.systemPackages)));
}
