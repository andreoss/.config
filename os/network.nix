{ lib, config, pkgs, ... }:
let
  change-mac = pkgs.writeShellScript "change-mac" ''
    PATH=${lib.strings.makeBinPath [ pkgs.iproute2 pkgs.macchanger ]}:$PATH
    IFDEV="$1"
    if [ -z "$IFDEV" -o ! -e "/sys/class/net/$IFDEV" ]
    then
      echo "No such device: $IFDEV"
      exit 0
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
  environment = {
    variables.JAVAX_NET_SSL_TRUSTSTORE = "/etc/ssl/certs/java/keystore.jks";
    variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    variables.CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    variables.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    systemPackages = with pkgs; [ traceroute dig.dnsutils jwhois ];
    etc."ssl/certs/java/keystore.jks".source = let
      caBundle = config.environment.etc."ssl/certs/ca-bundle.crt".source;
      p11kit = pkgs.p11-kit.overrideAttrs
        (oldAttrs: { configureFlags = [ "--with-trust-paths=${caBundle}" ]; });
    in derivation {
      name = "java-cacerts";
      builder = pkgs.writeShellScript "java-cacerts-builder" ''
        ${p11kit.bin}/bin/trust \
          extract \
          --format=java-cacerts \
          --purpose=server-auth \
          $out
      '';
      system = pkgs.system;
    };
    etc."ssl/proxy/cert.crt" = {
      text = builtins.readFile ../secrets/ssl/ca-cert.crt;
      user = "privoxy";
      group = "privoxy";
      mode = "0400";
    };
    etc."ssl/proxy/key.pem" = {
      text = builtins.readFile ../secrets/ssl/ca-key.pem;
      user = "privoxy";
      group = "privoxy";
      mode = "0400";
    };
  };
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
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      enable = true;
      allowPing = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
      extraCommands = ''
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT
        iptables -I OUTPUT -o wlan+ -m owner \! --gid-owner tunnel -j REJECT
        iptables -I OUTPUT -o eth+  -m owner \! --gid-owner tunnel -j REJECT
        iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
        iptables -A nixos-fw -p udp --source 192.168.99.0/28 --dport 53 -j nixos-fw-accept
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
      wait = "background";
      runHook =
        "if [[ $reason =~ BOUND ]]; then echo $interface: Routers are $new_routers - were $old_routers; fi";
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
      ../secrets/ssl/ca-cert.crt
    ];
    pki.caCertificateBlacklist = [ "CFCA EV ROOT" ];
  };
  services = {
    privoxy.enable = true;
    privoxy.inspectHttps = true;
    privoxy.certsLifetime = "1d";
    privoxy.userFilters = ''
      CLIENT-HEADER-FILTER: ua-fixes-os Fix UA
      s/[(]\w+; Linux \w+[)]/(Windows NT 10.0; rv:109.0)/ig
      CLIENT-HEADER-FILTER: ua-fixes-qt Fix UA
      s|[ ]?QtWebEngine[/]\S+||i
    '';
    privoxy.userActions = ''
      #
      { +crunch-client-header{sec-ch-ua} }
      /

      #
      { +client-header-filter{ua-fixes-os} }
      /

      #
      { +client-header-filter{ua-fixes-qt} }
      /
    '';
    privoxy.settings = {
      ca-cert-file = "/etc/ssl/proxy/cert.crt";
      ca-key-file = "/etc/ssl/proxy/key.pem";
      ca-password = "1234";
    };
  };
  system.activationScripts = {
    fix-rfkill.text = let path = lib.strings.makeBinPath [ pkgs.util-linux ];
    in ''
      ${path}/rfkill block   all
      ${path}/rfkill unblock all
    '';
    restart-unbound.text =
      "${pkgs.systemd}/bin/systemctl restart unbound.service";
  };
  services.openvpn.servers = import ../secrets/vpn.nix {
    inherit lib;
    inherit pkgs;
  };
  systemd.network.wait-online.timeout = 10;
  systemd.globalEnvironment = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
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
      restartTriggers = [ config.environment.etc."version".source ];
      postStart = restartUnbound;
      conflicts =
        map (y: "openvpn-${y}.service") (builtins.filter (y: y != x) cfx);
      serviceConfig.Group = "tunnel";
    };
  }) cfx));
}
