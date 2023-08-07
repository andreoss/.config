{ lib, config, pkgs, ... }:
let
  change-mac = pkgs.writeShellScript "change-mac" ''
    PATH=${lib.strings.makeBinPath [ pkgs.iproute2 pkgs.macchanger ]}:$PATH
    IFDEV="$1"
    if [ -z "$IFDEV" -o ! -e "/sys/class/net/$IFDEV" ]
    then
      echo "No such device: $IFDEV"
      exit 1
    fi
    ip link set "$IFDEV" down &&
    macchanger -b -r "$IFDEV"
    ip link set "$IFDEV" up
  '';
  macchanger-service = interface: {
    enable = true;
    description = "macchanger on ${interface}";
    partOf = [ "network.target" ];
    wants = [ "network-pre.target" ];
    before = [ "network-pre.target" ];
    bindsTo = [ "sys-subsystem-net-devices-${interface}.device" ];
    after = [ "sys-subsystem-net-devices-${interface}.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${change-mac} ${interface}";
    };
  };
  networks = builtins.tryEval {
    networks = import ../secrets/networks.nix;
    environmentFile = pkgs.writeShellScript "secrets.env"
      (builtins.readFile ../secrets/network.env);
  };
in {
  users.groups = { tunnel = { members = [ "sshd" ]; }; };
  environment.systemPackages = with pkgs; [ traceroute ];
  programs.bandwhich.enable = true;
  networking = {
    dns-crypt.enable = true;
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "tun0";
    };
    timeServers = [ ];
    networkmanager = { enable = lib.mkForce false; };
    enableIPv6 = lib.mkForce false;
    firewall = {
      extraPackages = with pkgs; [ ipset ];
      allowedTCPPorts = [ 4713 ];
      allowedUDPPorts = [ ];
      enable = true;
      allowPing = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
      extraCommands = ''
        iptables -I OUTPUT -o wlan+ -m owner \! --gid-owner tunnel -j REJECT
        iptables -I OUTPUT -o eth+  -m owner \! --gid-owner tunnel -j REJECT
        iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

        iptables -A nixos-fw -p udp --source 192.168.99.0/28 --dport 53 -j nixos-fw-accept
        ipset create local hash:net
        ipset add local 192.168.0.0/16
        ipset add local 172.16.0.0/16
        ipset add local 10.0.0.0/8

        iptables -I INPUT -m set --match-set local src -j ACCEPT
        iptables -I OUTPUT -m set --match-set local src -j ACCEPT
      '';
      extraStopCommands = ''
        iptables -D nixos-fw -p udp --source 192.168.99.0/28 --dport 53 -j nixos-fw-accept || true
      '';
    };

    resolvconf = {
      enable = true;
      extraConfig = "";
    };
    proxy = {
      allProxy = "http://127.0.0.1:8118";
      httpsProxy = "http://127.0.0.1:8118";
      httpProxy = "http://127.0.0.1:8118";
      ftpProxy = "http://127.0.0.1:8118";
      default = "http://127.0.0.1:8118";
    };
    usePredictableInterfaceNames = false;
    wireless = {
      enable = true;
      dbusControlled = true;
      scanOnLowSignal = false;
      userControlled.enable = true;
      networks = if networks.success then networks.value.networks else { };
      environmentFile = if networks.success then
        networks.value.environmentFile
      else
        (pkgs.writeShellScript "empty.env" "");
    };
    dhcpcd = {
      enable = true;
      allowInterfaces = [ "eth*" "wlan*" ];
    };
  };
  security = let russianCa = "https://gu-st.ru/content/lending/";
  in {
    pki.certificateFiles = with builtins; [
      (fetchurl {
        url = "${russianCa}/russian_trusted_root_ca_pem.crt";
        sha256 = "sha256:0135zid0166n0rwymb38kd5zrd117nfcs6pqq2y2brg8lvz46slk";
      })
      (fetchurl {
        url = "${russianCa}/russian_trusted_sub_ca_pem.crt";
        sha256 = "sha256:19jffjrawgbpdlivdvpzy7kcqbyl115rixs86vpjjkvp6sgmibph";
      })
    ];
    pki.caCertificateBlacklist = [ "CFCA EV ROOT" ];
  };
  services = {
    privoxy.enable = true;
    privoxy.inspectHttps = false;
    privoxy.settings = { };
  };
  services.openvpn.servers = import ../secrets/vpn.nix {
    inherit lib;
    inherit pkgs;
  };
  systemd.services = let
    restartUnbound = "${pkgs.systemd}/bin/systemctl restart unbound.service";
  in {
    dhcpcd = { partOf = [ "network.target" ]; };
    macchanger-wlan0 = macchanger-service "wlan0";
  } // (let
    merge = builtins.foldl' (x: y: x // y) { };
    cfx = builtins.attrNames config.services.openvpn.servers;
  in merge (map (x: {
    "openvpn-${x}" = {
      postStart = restartUnbound;
      conflicts =
        map (y: "openvpn-${y}.service") (builtins.filter (y: y != x) cfx);
      serviceConfig.Group = "tunnel";
    };
  }) cfx));
}
