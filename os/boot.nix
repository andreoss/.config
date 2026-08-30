{
  lib,
  config,
  pkgs,
  ...
}:
{
  hardware.enableRedistributableFirmware = true;
  boot = {
    kernelPackages = pkgs.${config.kernel};
    extraModulePackages = [
      config.boot.kernelPackages.rtl8821cu
      config.boot.kernelPackages.v4l2loopback
    ];
    kernelParams = [
      "boot.shell_on_fail"
      "consoleblank=0"
      "ipv6.disable=1"
      "mem_sleep_default=deep"
      "psi=1"
      "udev.log_priority=3"
      "usbcore.autosuspend=-1"
      "nvme_core.default_ps_max_latency_us=0"
      "nvme.poll_queues=4"
      "nvme_core.io_timeout=1"
    ];
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
      options usbcore autosuspend=-1
      options binder_linux devices=binder,hwbinder,vndbinder
    '';
    consoleLogLevel = 0;
    blacklistedKernelModules = [
      "snd_pcsp"
      "pcspkr"
      "bluetooth"
      "nouveau"
      "rivafb"
      "nvidiafb"
      "rivatv"
      "nv"
    ];
    supportedFilesystems = lib.mkForce [
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
      "ext4"
      "btrfs"
    ];
  };
  system.activationScripts.uuidgen = ''
    rm --force /etc/machine-id /var/lib/dbus/machine-id
    ${pkgs.dbus}/bin/dbus-uuidgen --ensure=/etc/machine-id
    ${pkgs.dbus}/bin/dbus-uuidgen --ensure
  '';
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultOOMPolicy = "kill";
    ShowStatus = "error";
  };
  services.gpm.enable = lib.mkForce true;
}
