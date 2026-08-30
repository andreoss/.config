{
  lib,
  config,
  pkgs,
  ...
}:
let
  supplicant-service = (
    interface: {
      configFile = {
        path = "/var/db/wpa_supplicant.conf";
        writable = true;
      };
      userControlled = {
        enable = true;
        group = "wheel";
      };
    }
  );
in
{
  networking = {
    timeServers = [ ];
    networkmanager = {
      enable = lib.mkForce false;
    };
    enableIPv6 = lib.mkForce false;
    firewall = {
      trustedInterfaces = [
        "docker0"
        "virbr*"
      ];
      extraPackages = with pkgs; [ ipset ];
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      enable = true;
      allowPing = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
    };
    resolvconf = {
      enable = true;
      extraConfig = "";
    };
    proxy = {
      noProxy = "gcr.io,zoom.us,slack.com";
    };
    usePredictableInterfaceNames = false;
    extraHosts = config.extraHosts;
    supplicant."wlan0" = supplicant-service "wlan0";
    supplicant."wlan1" = supplicant-service "wlan1";
    dhcpcd = {
      wait = "background";
      runHook = "if [[ $reason =~ BOUND ]]; then echo $interface: Routers are $new_routers - were $old_routers; fi";
      enable = true;
      allowInterfaces = [
        "eth*"
        "usb*"
        "wlan*"
      ];
      extraConfig = ''
        ipv4only
        debug
        noipv6

        ${config.dhcpcdExtraConfig config.preferedLocalIp}

        anonymous
        randomise_hwaddr
      '';
    };
  };
  system.activationScripts = {
    fix-rfkill.text =
      let
        path = lib.strings.makeBinPath [ pkgs.util-linux ];
      in
      ''
        if [ -e /dev/rfkill ]
        then
           ${path}/rfkill block   all
           ${path}/rfkill unblock all
        fi
      '';
    restart-unbound.text = "${pkgs.systemd}/bin/systemctl restart unbound.service";
  };
  systemd.network.wait-online.timeout = 10;
  systemd.services = {
    dhcpcd = {
      serviceConfig.ReadWritePaths = lib.mkForce [ ];
      partOf = [ "network.target" ];
    };
    supplicant-wlan0 = {
      requires = [ "macchanger-wlan0.service" ];
      bindsTo = [ "sys-subsystem-net-devices-wlan0.device" ];
      conflicts = [ "supplicant-wlan1.service" ];
      before = [ "macchanger-wlan0.service" ];
      serviceConfig = {
        ExecCondition = "${pkgs.bash}/bin/bash -c '[ -e /sys/class/net/wlan0 ] && [ ! -e /sys/class/net/wlan1 ]'";
      };
    };
    supplicant-wlan1 = {
      requires = [ "macchanger-wlan1.service" ];
      before = [ "macchanger-wlan1.service" ];
      bindsTo = [ "sys-subsystem-net-devices-wlan1.device" ];
      conflicts = [ "supplicant-wlan0.service" ];
      serviceConfig = {
        ExecCondition = "${pkgs.bash}/bin/bash -c '[ -e /sys/class/net/wlan1 ]'";
      };
    };
  };
}
