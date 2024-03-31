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
        iptables -I OUTPUT -o wlan+ -m owner \! --gid-owner tunnel -j REJECT
        iptables -I OUTPUT -o eth+  -m owner \! --gid-owner tunnel -j REJECT
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
  systemd.services = { } // (let
    merge = builtins.foldl' (x: y: x // y) { };
    cfx = builtins.attrNames config.services.openvpn.servers;
  in merge (map (x: {
    "openvpn-${x}" = {
      restartTriggers = [ config.environment.etc."nixos/version".source ];
      postStart = "${pkgs.systemd}/bin/systemctl restart unbound.service";
      conflicts =
        map (y: "openvpn-${y}.service") (builtins.filter (y: y != x) cfx);
      serviceConfig.Group = "tunnel";
    };
  }) cfx));
}
