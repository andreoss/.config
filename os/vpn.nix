{ lib, config, pkgs, ... }: {
  users.groups = { tunnel = { }; };
  networking = {
    nat = {
      enable = true;
      externalInterface = "tun0";
    };
    firewall = {
      trustedInterfaces = [ "docker0" "br*" ];
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
  services.openvpn.servers = import ../secrets/vpn.nix {
    inherit lib;
    inherit pkgs;
  };
  systemd.timers = { } // (let
    merge = builtins.foldl' (x: y: x // y) { };
    cfx = builtins.attrNames config.services.openvpn.servers;
  in merge (map (x: {
    "openvpn-${x}-health-check" = {
      conflicts = map (y: "openvpn-${y}-health-check.timer")
        (builtins.filter (y: y != x) cfx);
      timerConfig = {
        Unit = "openvpn-${x}-health-check.service";
        OnUnitActiveSec = "30";
        RandomizedDelaySec = "30";
        OnCalendar = "minutely";
      };
    };
  }) cfx));
  systemd.services = { } // (let
    merge = builtins.foldl' (x: y: x // y) { };
    cfx = builtins.attrNames config.services.openvpn.servers;
  in merge (map (x: {
    "openvpn-${x}" = {
      requires = [ "openvpn-${x}-health-check.timer" ];
      restartTriggers = [ config.environment.etc."nixos/version".source ];
      postStart = "${pkgs.systemd}/bin/systemctl restart unbound.service";
      conflicts =
        map (y: "openvpn-${y}.service") (builtins.filter (y: y != x) cfx);
      serviceConfig = { Group = "tunnel"; };
    };
    "openvpn-${x}-restart" = {
      script = "${pkgs.systemd}/bin/systemctl restart openvpn-${x}.service";
      conflicts =
        map (y: "openvpn-${y}.service") (builtins.filter (y: y != x) cfx);
      serviceConfig = { Type = "oneshot"; };
    };
    "openvpn-${x}-health-check" = {
      script = ''
        ${pkgs.iputils}/bin/ping -c 4 209.51.188.116
      '';
      restartTriggers = [ config.environment.etc."nixos/version".source ];
      conflicts =
        map (y: "openvpn-${y}.service") (builtins.filter (y: y != x) cfx);
      onFailure = [ "openvpn-${x}-restart.service" ];
      serviceConfig = { Type = "oneshot"; };
    };
  }) cfx));
}
