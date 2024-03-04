{ lib, config, pkgs, ... }:
let palette = import ./palette.nix;
in {
  hardware.enableRedistributableFirmware = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "boot.shell_on_fail"
      "consoleblank=0"
      "ipv6.disable=1"
      "mem_sleep_default=deep"
      "psi=1"
      "udev.log_priority=3"
      "usbcore.autosuspend=-1"
    ];
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
      options binder_linux devices=binder,hwbinder,vndbinder
    '';
    kernel.sysctl = {
      "vm.swappiness" = 1;
      # Disable magic SysRq key
      "kernel.sysrq" = 0;
      # Ignore ICMP broadcasts to avoid participating in Smurf attacks
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # Ignore bad ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse-path filter for spoof protection
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;
      # Do not send ICMP redirects (we are not a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      # Do not accept IP source route packets (we are not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Protect against tcp time-wait assassination hazards
      "net.ipv4.tcp_rfc1337" = 1;
      # TCP Fast Open (TFO)
      "net.ipv4.tcp_fastopen" = 3;
      ## Bufferbloat mitigations
      # Requires >= 4.9 & kernel module
      "net.ipv4.tcp_congestion_control" = "bbr";
      # Requires >= 4.19
      "net.core.default_qdisc" = "cake";
      "fs.inotify.max_user_watches" = 1048576; # default:  8192
      "fs.inotify.max_user_instances" = 1024; # default:   128
      "fs.inotify.max_queued_events" = 32768; # default: 16384
    };
    consoleLogLevel = 0;
    blacklistedKernelModules = [ "snd_pcsp" "pcspkr" "bluetooth" ];
    initrd = {
      kernelModules = [
        "ahci"
        "amdgpu"
        "nvme"
        "sd_mod"
        "sr_mod"
        "uas"
        "usbhid"
        "usb_storage"
        "vfio-pci"
        "xhci_pci"
      ];
      verbose = true;
    };
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    supportedFilesystems =
      lib.mkForce [ "vfat" "f2fs" "xfs" "ntfs" "ext4" "btrfs" ];
  };
  console = {
    packages = [ pkgs.uw-ttyp0 ];
    font = "t0-18b-uni";
    colors = builtins.map (x: builtins.replaceStrings [ "#" ] [ "" ] x)
      (with palette; [
        black1
        red1
        green1
        yellow1
        blue1
        red3
        cyan1
        white3
        black2
        orange1
        gray1
        gray2
        gray3
        magenta
        red3
        white1
      ]);
  };
  system.activationScripts.uuidgen = ''
    rm --force /etc/machine-id /var/lib/dbus/machine-id
    ${pkgs.dbus}/bin/dbus-uuidgen --ensure=/etc/machine-id
    ${pkgs.dbus}/bin/dbus-uuidgen --ensure
  '';
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=10s
    DefaultTimeoutStopSec=10s
    DefaultOOMPolicy=kill
    ShowStatus=error
  '';
  services.gpm.enable = lib.mkForce true;
}
