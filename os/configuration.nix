{ lib, config, pkgs, home-manager, guix-overlay,  self, ... }:
let user = self.config.primaryUser.name;
in {
  nixpkgs.config = {
    allowUnfree = false;
    packageOverrides = pkgs: {
      grub2 = (pkgs.grub2.override { }).overrideAttrs (attrs: {
        patches = [ ./01-quite.patch ./02-no-uuid.patch ] ++ attrs.patches;
      });
    };
  };
  services.dbus = {
    enable = true;
    packages = [ pkgs.gcr ];
  };
  programs.dconf.enable = true;
  system.copySystemConfiguration = false;
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "01:00";
    randomizedDelaySec = "10min";
  };
  services.getty.extraArgs = [ "--nohostname" "--noissue" "--noclear" "--nohints" ];
  services.cron.systemCronJobs = [ "0 2 * * * root fstrim /" ];
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 1;
  };
}
