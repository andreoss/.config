{
  lib,
  config,
  pkgs,
  ...
}:
let
  isOn = (x: (builtins.elem x config.features));
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
  change-mac = pkgs.writeShellScript "change-mac" ''
    PATH=${
      lib.strings.makeBinPath [
        pkgs.iproute2
        pkgs.macchanger
      ]
    }:$PATH
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
    before = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = "${pkgs.bash}/bin/bash -c '[ -e /sys/class/net/${interface}]'";
      ExecStart = "${change-mac} ${interface}";
    };
  };
  keystore = "/etc/ssl/certs/java/keystore.jks";
in
{
  systemd.globalEnvironment = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };
  system.activationScripts = {
    generate-keystore-jks.text =
      let
        path = lib.strings.makeBinPath [ pkgs.p11-kit ];
      in
      ''
        PATH="$PATH:${path}"
        rm --force ${keystore}
        mkdir --parent $(dirname ${keystore})
        trust \
          extract \
          --format=java-cacerts \
          --purpose=server-auth \
          ${keystore}
      '';
  };
  environment = lib.mkIf config.sslProxy.enable {
    systemPackages = with pkgs; [
      traceroute
      dig.dnsutils
      jwhois
      wirelesstools
    ];
    variables.JAVAX_NET_SSL_TRUSTSTORE = keystore;
    variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    variables.CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    variables.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    etc."ssl/proxy/cert.crt" = {
      text = config.sslProxy.crt;
      user = "privoxy";
      group = "privoxy";
      mode = "0400";
    };
    etc."ssl/proxy/key.pem" = {
      text = config.sslProxy.crt;
      user = "privoxy";
      group = "privoxy";
      mode = "0400";
    };
  };
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
      # allProxy = "http://127.0.0.1:8118";
      # httpsProxy = "http://127.0.0.1:8118";
      # httpProxy = "http://127.0.0.1:8118";
      # ftpProxy = "http://127.0.0.1:8118";
      # default = "http://127.0.0.1:8118";
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
        ${config.dhcpcdExtraConfig config.preferedLocalIp}
      '';
    };
  };
  security =
    let
      russianCa = "https://gu-st.ru/content/lending/";
    in
    {
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
  services = lib.mkIf config.sslProxy.enable {
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
      partOf = [ "network.target" ];
    };
    macchanger-wlan0 = macchanger-service "wlan0";
    macchanger-wlan1 = macchanger-service "wlan1";
    macchanger-eth0 = macchanger-service "eth0";
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
