{ inputs, lib, config, pkgs, ... }:
let
  change-mac = pkgs.writeShellScript "change-mac" ''
    card="$1"
    if [ -z "$1" -o ! -e "/sys/class/net/$card" ]
    then
      echo "No such device: $card"
      exit 1
    fi
    ${pkgs.iproute2}/bin/ip link set "$card" down &&
    ${pkgs.macchanger}/bin/macchanger -b -r "$card"
    ${pkgs.iproute2}/bin/ip link set "$card" up
  '';
  networks = builtins.tryEval {
    networks = import ../secrets/networks.nix;
    environmentFile = pkgs.writeShellScript "secrets.env"
      (builtins.readFile ../secrets/network.env);
  };
in {
  networking = {
    enableIPv6 = lib.mkForce false;
    timeServers = [ ];
    extraHosts =
      builtins.readFile "${inputs.hosts}/alternates/gambling-porn-social/hosts";
    networkmanager = {
      enable = lib.mkForce false;
      insertNameservers = [ "127.0.0.1" ];
    };
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      enable = true;
      allowPing = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
      extraCommands = ''
        iptables -I OUTPUT -o wlan+ -m owner \! --gid-owner tunnel -j REJECT
        iptables -I OUTPUT -o eth+  -m owner \! --gid-owner tunnel -j REJECT
      '';
    };
    resolvconf.enable = true;
    resolvconf.extraConfig = "";
    nameservers = [ "127.0.0.1" ];
    proxy = {
      allProxy = "http://127.0.0.1:8118";
      httpsProxy = "http://127.0.0.1:8118";
      httpProxy = "http://127.0.0.1:8118";
      ftpProxy = "http://127.0.0.1:8118";
      default = "http://127.0.0.1:8118";
    };
    usePredictableInterfaceNames = false;
    wireless.enable = true;
    wireless.dbusControlled = true;
    wireless.scanOnLowSignal = false;
    wireless.userControlled.enable = true;
    wireless.networks =
      if networks.success then networks.value.networks else { };
    wireless.environmentFile = if networks.success then
      networks.value.environmentFile
    else
      (pkgs.writeShellScript "empty.env" "");
    dhcpcd = {
      enable = true;
      extraConfig = ''
        duid
        noarp
        static domain_name_servers=127.0.0.1
      '';
      allowInterfaces = [ "eth*" "wlan*" ];
    };
  };
  security = {
    pki.certificateFiles = [ ];
    pki.caCertificateBlacklist = [ "CFCA EV ROOT" ];
  };
  services = {
    privoxy.enable = true;
    privoxy.inspectHttps = false;
    privoxy.settings = { };
    unbound = {
      enable = true;
      resolveLocalQueries = true;
      enableRootTrustAnchor = false;
      settings = {
        server = {
          interface = [ "127.0.0.1" ];
          do-not-query-localhost = "no";
          hide-identity = "yes";
          hide-version = "yes";
          verbosity = 4;
          prefetch = "yes";
          prefetch-key = "yes";
          minimal-responses = "yes";
        };
        forward-zone = [{
          name = ".";
          forward-addr = [ "127.0.0.1@5553" ];
        }];
      };
    };
    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = false;
        require_dnssec = true;
        listen_addresses = [ "127.0.0.1:5553" ];
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key =
            "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      };
    };
  };
  systemd.services.unbound = { partOf = [ "network.target" ]; };
  systemd.services.dnscrypt-proxy2 = {
    requires = [ "unbound.service" ];
    partOf = [ "network.target" ];
  };
  systemd.services.dhcpcd = { partOf = [ "network.target" ]; };
  systemd.services.macchanger-wlan = {
    enable = true;
    description = "macchanger on wlan0";
    partOf = [ "network.target" ];
    wants = [ "network-pre.target" ];
    before = [ "network-pre.target" ];
    bindsTo = [ "sys-subsystem-net-devices-wlan0.device" ];
    after = [ "sys-subsystem-net-devices-wlan0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${change-mac} wlan0";
    };
  };
  systemd.services.macchanger-eth = {
    enable = true;
    description = "macchanger on eth0";
    partOf = [ "network.target" ];
    wants = [ "network-pre.target" ];
    before = [ "network-pre.target" ];
    bindsTo = [ "sys-subsystem-net-devices-eth0.device" ];
    after = [ "sys-subsystem-net-devices-eth0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${change-mac} eth0";
    };
  };
  services.openvpn.servers = import ../secrets/vpn.nix {
    inherit lib;
    inherit pkgs;
  };
  systemd.services."openvpn-f1".serviceConfig.Group = "tunnel";
  systemd.services."openvpn-m1".serviceConfig.Group = "tunnel";
  environment = {
    etc = {
      "resolv.conf" = {
        mode = "0444";
        source = lib.mkOverride 0 (pkgs.writeText "resolv.conf" ''
          nameserver 127.0.0.1
          nameserver 127.0.0.2
        '');
      };
    };
  };
}
