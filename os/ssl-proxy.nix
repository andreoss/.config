{
  lib,
  config,
  pkgs,
  ...
}:
let
  keystore = "/etc/ssl/certs/java/keystore.jks";
in
{
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
      namespaced-openvpn
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
}
