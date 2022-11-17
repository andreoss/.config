{ config, inputs, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];
  isoImage = {
    efiSplashImage = ./../wp/1.jpeg;
    splashImage = ./../wp/1.jpeg;
  };
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.verbose = false;
  boot.kernel.sysctl = {
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
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
    logo = ./wallpapers/1.png;
    font = "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF-Bold.ttf";
  };
  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-132n";
    earlySetup = false;
    useXkbConfig = true;
    colors = builtins.map (x: builtins.replaceStrings [ "#" ] [ "" ] x) [
      "#000000"
      "#AE322F"
      "#859900"
      "#B58900"
      "#268BAE"
      "#D33682"
      "#2AAF98"
      "#EAEAAA"
      "#002B36"
      "#AE4B16"
      "#586E75"
      "#657B83"
      "#839496"
      "#6C71EA"
      "#AEA1A1"
      "#FFFFAA"
    ];
  };
}
