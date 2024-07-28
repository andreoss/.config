{
  interface ? "wlan1",
  bridge ? "virbr0",
  ssid,
  passphrase,
  ...
}:
let
  hostapd-conf = pkgs.writeShellScript "hostapd.conf" ''
    interface=${interface}
    bridge=${bridge}
    ssid=${ssid}
    wpa_passphrase=${passphrase}

    channel=7
    ap_max_inactivity=1800
    auth_algs=1
    disable_pmksa_caching=1
    disassoc_low_ack=0
    eapol_key_index_workaround=1
    nas_identifier=
    okc=0
    skip_inactivity_poll=1
    wmm_enabled=0
    utf8_ssid=1
    wpa=2
    wpa_group_rekey=3600
    wpa_key_mgmt=WPA-PSK
    rsn_pairwise=CCMP
    country_code=MX
    time_advertisement=2
    beacon_prot=1
  '';
in
{
  systemd.services = {
    hostapd = {
      enable = true;
      description = "hostapd - ${interface}";
      before = [ "kea-dhcp4-server.service" ];
      wantedBy = [ "network.target" ];
      serviceConfig = {
        ExecStartPre = "${pkgs.inetutils}/bin/ifconfig ${interface} up";
        ExecStart = "${pkgs.hostapd}/bin/hostapd -t -d ${hostapd-conf}";
        Restart = "always";
        RestartSec = "3";
        Type = "idle";
      };
    };
  };
}
