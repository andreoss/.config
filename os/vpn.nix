{
  lib,
  config,
  pkgs,
  ...
}:
{
  users.groups = {
    tunnel = { };
  };
  networking = {
    nat = {
      enable = true;
      externalInterface = "tun0";
    };
    firewall = {
      trustedInterfaces = [
        "docker0"
        "br*"
      ];
      extraPackages = with pkgs; [ ipset ];
      extraCommands = lib.mkForce ''
        # Kill switch
        iptables -A INPUT  -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT
        iptables -I OUTPUT -o wlan+ -m owner \! --gid-owner tunnel -j DROP
        iptables -I OUTPUT -o eth+  -m owner \! --gid-owner tunnel -j DROP
        iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
      '';
      extraStopCommands = "";
    };
  };
  services.openvpn.restartAfterSleep = true;
  services.openvpn.servers = { };
}
