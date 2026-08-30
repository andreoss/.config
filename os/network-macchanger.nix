{
  lib,
  config,
  pkgs,
  ...
}:
let
  change-mac = pkgs.writeShellScript "change-mac" ''
    PATH=${
      lib.strings.makeBinPath [
        pkgs.iproute2
        pkgs.macchanger
      ]
    }:$PATH
    IF="$1"
    if [ -z "$IF" -o ! -e "/sys/class/net/$IF" ]
    then
      echo "No such device: $IF"
      exit 0
    fi
    ip link set "$IF" down &&
    macchanger --bia "$IF"
    ip link set "$IF" up
  '';
  change-mac-notify = pkgs.writeShellScript "change-mac-notify" ''
    PATH=${
      lib.strings.makeBinPath [
        pkgs.dbus
        pkgs.macchanger
      ]
    }:$PATH
    IF="$1"
    if [ -z "$IF" -o ! -e "/sys/class/net/$IF" ]
    then
      echo "No such device: $IF"
      exit 0
    fi
    dbus-send --system / net.nuetzlich.SystemNotifications.Notify "string:$IF" "string:$(macchanger --show $IF | head -1)"
  '';
  macchanger-service = interface: {
    enable = true;
    description = "macchanger on ${interface}";
    partOf = [ "network.target" ];
    before = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = "${pkgs.bash}/bin/bash -c '[ -e /sys/class/net/${interface} ]'";
      ExecStart = "${change-mac} ${interface}";
      ExecStartPost = "${change-mac-notify} ${interface}";
    };
  };
in
{
  systemd.services = {
    macchanger-wlan0 = macchanger-service "wlan0";
    macchanger-wlan1 = macchanger-service "wlan1";
    macchanger-eth0 = macchanger-service "eth0";
  };
}
